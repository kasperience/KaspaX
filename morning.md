# Morning Integration Checklist

- Verify service: `systemctl --user status kaspa-auth` and confirm socket `%t/kaspa-auth.sock` exists.
- Run verifier: `applications/kdapps/kaspa-auth/scripts/verify-first-login.sh --repair`.
- Wizard check: `applications/kdapps/kaspa-auth/scripts/kaspa-first-login-wizard.sh` (use `--force` to re-run).
- Storage mode: `applications/kdapps/kaspa-auth/scripts/set-storage-mode.sh dev|keychain` then `systemctl --user daemon-reload && systemctl --user restart kaspa-auth.service`.
- Key migration: `applications/kdapps/kaspa-auth/scripts/import-dev-key-to-keychain.sh --username participant-peer`.
- Logs: `journalctl --user -u kaspa-auth -f` for live output.

Notes:
- File storage dir: `KASPA_AUTH_DATA_DIR=$HOME/.local/share/kaspa-auth`.
- Toggle keychain mode temporarily by env: `KASPAX_USE_KEYCHAIN=1`.
qpexn3c4qqccx8deugzv8er4u8z79mhrspzyahqahpp4wsy4zn48wjx3uxskj
