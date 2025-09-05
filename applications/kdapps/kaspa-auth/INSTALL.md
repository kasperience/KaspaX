# Kaspa Auth — Install (Arch + Hyprland)

This guide covers installing and verifying the Kaspa Auth daemon as a user service.

## Prerequisites
- `~/.cargo/bin/kaspa-auth` installed (built from this repo)
- Desktop session with `xdg-open`
- `gnome-keyring` + `libsecret` for keychain mode
- Optional: `qrencode` for QR generation

## Install Steps
- Choose storage mode and install the user service:
  - Keychain (recommended):
    - `bash applications/kdapps/kaspa-auth/scripts/set-storage-mode.sh keychain`
  - Dev (file-backed, for testing):
    - `bash applications/kdapps/kaspa-auth/scripts/set-storage-mode.sh dev`
- Verify and auto-repair if needed:
  - `bash applications/kdapps/kaspa-auth/scripts/verify-first-login-enhanced.sh --repair`
- Run the first-login wizard (safe to re-run with `--force`):
  - Keychain: `KASPAX_USE_KEYCHAIN=1 bash applications/kdapps/kaspa-auth/scripts/kaspa-first-login-wizard.sh --force`

## Quick Checks
- Daemon status:
  - `~/.cargo/bin/kaspa-auth daemon status --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock"`
- Ping:
  - `~/.cargo/bin/kaspa-auth daemon send --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock" ping`
- Wallet (keychain):
  - `~/.cargo/bin/kaspa-auth --keychain wallet-status --username participant-peer`

## Troubleshooting
If the service crash-loops or the socket exists but the CLI cannot connect:

- Verifier with repair:
  - `bash applications/kdapps/kaspa-auth/scripts/verify-first-login.sh --repair`
- If logs show `the argument '--keychain' cannot be used multiple times`:
  - Dedupe flags and restart:
    - `bash applications/kdapps/kaspa-auth/scripts/repair-user-unit.sh`
    - `systemctl --user reset-failed kaspa-auth.service && systemctl --user restart kaspa-auth.service`
- Rebuild the unit explicitly (safe to re-run):
  - `bash applications/kdapps/kaspa-auth/scripts/set-storage-mode.sh keychain` (or `dev`)
- See also: `applications/kdapps/kaspa-auth/UNIT_TROUBLESHOOTING.md`.

## Notes
- Systemd hardening: `ProtectHome=read-only` with `ReadWritePaths=%h/.local/share %t` allows CLI in `~/.cargo/bin`, data in `~/.local/share`, and the runtime socket under `$XDG_RUNTIME_DIR`.
- The unit currently runs the daemon in dev or keychain mode depending on the script you use; production should prefer keychain.
