# Changelog

All notable changes to KaspaX in this session. Dates use YYYY-MM-DD.

## 2025-08-20

- systemd: Allow IPC socket creation under `$XDG_RUNTIME_DIR` by adding `%t` to `ReadWritePaths` in `applications/kdapps/kaspa-auth/systemd/kaspa-auth.service`.
- CLI: Clarified `daemon send` flag ordering. Use `daemon send --socket-path … ping` (flags before the subcommand).
- Verifier: `applications/kdapps/kaspa-auth/scripts/verify-first-login.sh` now uses correct ordering and includes `--repair` path to copy unit, reload, enable, and start.
- Splash: Dark theme fallbacks added; address now carries `kaspatest:`/`kaspa:` prefix based on `KASPA_NETWORK`. Faucet link only shown on testnet.
- Wizard: Passes network hint to splash; you can re-run with `--force` without touching the first-login marker.
- Dev-mode wallet: Daemon now loads/uses dev keys from `$KASPA_AUTH_DATA_DIR/.kaspa-auth/<username>.key` consistently for unlock/sign.
- Docs: Updated paths to treat this repo as standalone (`KaspaX` root). Fixed verify command examples and added unlock instructions.

Migrating existing setups
- Reinstall binary and restart service:
  - `cargo install --path applications/kdapps/kaspa-auth --bin kaspa-auth --force`
  - `systemctl --user daemon-reload && systemctl --user restart kaspa-auth.service`
- Verify and repair:
  - `bash applications/kdapps/kaspa-auth/scripts/verify-first-login.sh --repair`
- Unlock identity for signing in dev mode:
  - `~/.cargo/bin/kaspa-auth daemon send --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock" unlock --username participant-peer --password devpass`

