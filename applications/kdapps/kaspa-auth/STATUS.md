# KaspaX — kaspa-auth Status (2025-08-20)

This note captures tonight’s state, fixes applied, and how to resume tomorrow.

## Current State
- CLI installed: `~/.cargo/bin/kaspa-auth`.
- Systemd unit updated for user service:
  - `ProtectHome=read-only` (instead of `yes`) to allow executing from `~`.
  - `ReadWritePaths=%h/.local/share %t` to permit writes under `~/.local/share` and the runtime dir for the IPC socket.
  - Runs daemon in `--dev-mode` with `--data-dir %h/.local/share/kaspa-auth`.
  - Socket: `%t/kaspa-auth.sock` (`$XDG_RUNTIME_DIR/kaspa-auth.sock`).
- Wizard fixes:
  - Truly no-op after marker unless `--force`.
  - Ensures dev-mode wallet and extracts address for splash.
- Verifier (`scripts/verify-first-login.sh`):
  - New `--repair` mode copies the unit, ensures dirs, reloads/enables/starts.
  - Uses correct CLI form and flag order (e.g., `daemon send --socket-path … ping`).
  - Repairs unit and confirms socket, status, wallet.

## UI/UX
- Wizard splash now has robust dark styling even if palette CSS fails to load.
- Shows network badge and prefixes address: `kaspatest:` on testnet, `kaspa:` on mainnet.
- Faucet link is shown only on testnet.

## Dev-mode wallet consistency
- Daemon now loads dev-mode keys from the configured data dir (`$KASPA_AUTH_DATA_DIR`, default `~/.local/share/kaspa-auth/.kaspa-auth/<username>.key`) consistently for unlock/sign.

## CLI tips
- For `daemon send`, place flags before the subcommand:
  - `~/.cargo/bin/kaspa-auth daemon send --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock" ping`
- Unlock identity in daemon before `sign`:
  - `~/.cargo/bin/kaspa-auth daemon send --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock" unlock --username participant-peer --password devpass`

## Resume Steps (tomorrow)
1) Reinstall CLI (after tonight’s changes):
```
cargo install --path applications/kdapps/kaspa-auth --bin kaspa-auth --force
```
2) Repair + verify the service:
```
bash applications/kdapps/kaspa-auth/scripts/verify-first-login.sh --repair
bash applications/kdapps/kaspa-auth/scripts/verify-first-login.sh
```
3) Get the wallet address (creates if missing, dev-mode):
```
~/.cargo/bin/kaspa-auth --dev-mode wallet-status --username participant-peer --create
```
4) Fund on testnet: https://faucet.kaspanet.io/ → send to the address above (explorer: `https://explorer.kaspa.org/addresses/kaspatest:<address>`).
5) Run wizard (or relogin to trigger autostart):
```
bash applications/kdapps/kaspa-auth/scripts/kaspa-first-login-wizard.sh --force
```

## Troubleshooting
- Service status:
```
systemctl --user status kaspa-auth.service --no-pager -l
journalctl --user -xeu kaspa-auth.service --no-pager -l
```
- Socket checks:
```
ls -l "$XDG_RUNTIME_DIR/kaspa-auth.sock"
~/.cargo/bin/kaspa-auth daemon status --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock"
```
- Common root causes fixed tonight:
  - `203/EXEC` → caused by `ProtectHome=yes`; fixed by `ProtectHome=read-only` + `ReadWritePaths`.
  - CLI parsing → remove stray `--` before subcommands.

## Notes on Modes
- Dev-mode (current): key stored under `~/.local/share/kaspa-auth/.kaspa-auth/participant-peer.key` for easy setup/demo.
- Keyring mode (production): switch back by running daemon without `--dev-mode` and using `--keychain` in CLI/wizard.

— End of status
