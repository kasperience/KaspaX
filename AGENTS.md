# KaspaX — Agent Guide

This document orients AI/code agents working inside the KaspaX nested repository. Treat this repo as independent from the parent kdapp workspace, with its own commit history and release cadence.

## Scope & Structure
- Repo root: `KaspaX`
- Key areas:
  - `applications/kdapps/kaspa-auth/` — app bundle for kaspa-auth integration
    - `public/` — assets and HTML templates (splash)
    - `scripts/` — first-login wizard, installers, verifiers
    - `systemd/` — user service files for the daemon
  - Docs:
    - `KASPAX_FIRST_LOGIN.md` — first login + keyring + autostart guide
    - `applications/kdapps/kaspa-auth/INSTALL.md` — VM-friendly setup (Arch + Hyprland)

This repo is a “distribution surface” for the kdapp ecosystem on Linux — it wires desktop login, autostart, keyring, daemon, and first‑run UX.

## What You Can Change
- Shell scripts under `applications/kdapps/kaspa-auth/scripts/`:
  - `kaspa-first-login-wizard.sh` — main first-login flow; ensure daemon running, ensure wallet, show summary, open GUI splash.
  - `install-first-login-autostart.sh` — installs a `.desktop` entry to run wizard once.
  - `install-systemd-user.sh` — installs/enables `kaspa-auth.service` for current user.
  - `verify-first-login.sh` — quick end-to-end checker.
- Splash UI:
  - Template: `public/wizard_splash.template.html` (dark palette + kdapp logo)
  - Launcher: `scripts/show-wizard-splash.sh` (generates temp HTML, optional QR via `qrencode`)
- Systemd unit:
  - `systemd/kaspa-auth.service` — matches the CLI path and runtime socket.

Keep changes minimal and focused on Linux desktop integration and UX polish.

## Dependencies & Assumptions
- Installed CLI: `~/.cargo/bin/kaspa-auth` (built from this repo: `applications/kdapps/kaspa-auth`)
- Desktop session with `xdg-open`
- `gnome-keyring` + `libsecret` (PAM unlock for Secret Service)
- Optional: `qrencode` for on-device QR image generation
- First-run marker: `~/.local/share/kaspa-auth/.first_login_done`

## Conventions
- Commit style: Conventional commits (e.g., `feat(kaspax): …`, `fix(kaspax): …`, `docs(kaspax): …`).
- Shell style: `bash`, `set -euo pipefail`, explicit paths, informative logging.
- Security: never commit secrets; do not hardcode private keys or tokens; default to testnet docs.
- UX: terminal output via scripts; GUI splash opened with `xdg-open`; keep HTML self-contained.

## Common Tasks
- Update splash visuals:
  - Edit `public/wizard_splash.template.html`; keep logo path: `public/assets/kdapp_framework.jpg`.
  - If adding assets, place them under `public/assets/` and reference via `file://` URIs.
- Tweak first-run flow:
  - Edit `scripts/kaspa-first-login-wizard.sh`; preserve marker and daemon startup logic.
  - Any new wizard step should be safe to retry and idempotent.
- Service path changes:
  - Adjust `systemd/kaspa-auth.service` `ExecStart` and mirror the change in docs/scripts.

## Testing
- Install steps: see `applications/kdapps/kaspa-auth/INSTALL.md`.
- Quick verification: `scripts/verify-first-login.sh` (checks binary, systemd, socket, wallet, splash).
- Manual checks:
  - `~/.cargo/bin/kaspa-auth daemon status --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock"`
  - `~/.cargo/bin/kaspa-auth --dev-mode wallet-status --username participant-peer --create`

## Release & Repo Hygiene
- Treat this as a standalone repo. `cd KaspaX` before committing/pushing.
- Remote: `origin` typically points to GitHub (SSH recommended). Example:
  - `git remote set-url origin git@github.com:<org>/KaspaX.git`
  - `git push origin main`
- Avoid making parent-repo wide changes from here; keep scope to KaspaX packaging, docs, and scripts.

## Do/Don’t
- Do: keep scripts idempotent and resilient; prefer `systemctl --user` integration.
- Do: document exact commands users copy/paste in INSTALL.md.
- Don’t: introduce network calls in scripts that run at login (except local `xdg-open`).
- Don’t: depend on non-standard shells or distro-specific paths without guards.

## Pointers
- First login guide: `KASPAX_FIRST_LOGIN.md`
- Install guide: `applications/kdapps/kaspa-auth/INSTALL.md`
- Splash template: `applications/kdapps/kaspa-auth/public/wizard_splash.template.html`
- Wizard script: `applications/kdapps/kaspa-auth/scripts/kaspa-first-login-wizard.sh`

If behavior changes materially, update both guides and the verifier script.

## Current Status (2025-08-20)
- Service hardening fix: `ProtectHome=read-only` with `ReadWritePaths=%h/.local/share %t` to allow running the binary from `~/.cargo/bin`, writing under `~/.local/share`, and creating the socket under `$XDG_RUNTIME_DIR`.
- Unit runs daemon in dev mode for now: `--dev-mode` with `--data-dir %h/.local/share/kaspa-auth` and socket at `%t/kaspa-auth.sock`.
- Verifier script gains `--repair` to copy the unit, ensure dirs, reload/enable/start, then run checks.
- Wizard is idempotent and truly no-ops after `.first_login_done` unless `--force`.
- CLI usage: remove stray `--` before subcommands; for `daemon send` place flags before the inner action (e.g., `daemon send --socket-path … ping`).

## Important Conclusions
- 203/EXEC root cause was `ProtectHome=yes` preventing access to `~`. Fix by setting `ProtectHome=read-only` and allowing writes via `ReadWritePaths`.
- For first-run UX we use file-backed wallets (`--dev-mode`) so the wizard can create keys without keyring friction. Production should switch back to keyring.
- Prefer `KASPA_AUTH_DATA_DIR=~/.local/share/kaspa-auth` to keep files in XDG-friendly paths.
- Autostart entry is safe to keep: it checks a marker and exits quickly on subsequent logins.

## Storage Mode Toggle
- Runtime scripts honor `KASPAX_USE_KEYCHAIN=1` to use keychain flows.
- Systemd unit mode can be switched with:
```
bash applications/kdapps/kaspa-auth/scripts/set-storage-mode.sh dev
bash applications/kdapps/kaspa-auth/scripts/set-storage-mode.sh keychain
```
- After switching, run: `systemctl --user daemon-reload && systemctl --user restart kaspa-auth.service` (the script already does this).

## Migration: Dev Key → Keychain
- Import existing dev-mode key into keyring to keep the same address when switching modes:
```
bash applications/kdapps/kaspa-auth/scripts/import-dev-key-to-keychain.sh --username participant-peer
```
- Verifies via `kaspa-auth --keychain wallet-status` and requires `secret-tool` (libsecret) with an unlocked keyring.
