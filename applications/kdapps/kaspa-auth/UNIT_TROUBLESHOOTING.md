# Kaspa Auth Unit Troubleshooting

If the user unit crash-loops or `verify-first-login.sh` reports a socket present but the CLI cannot reach the daemon, you may have a stale socket or duplicated storage-mode flags in the unit.

Before restarting the unit, remove any leftover runtime socket:

```
if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  rm -f "${XDG_RUNTIME_DIR}/kaspa-auth.sock" || true
fi
```

Quick fix:

```
bash applications/kdapps/kaspa-auth/scripts/repair-user-unit.sh
systemctl --user reset-failed kaspa-auth.service
systemctl --user restart kaspa-auth.service
```

Rebuild the unit for a specific storage mode (idempotent):

```
bash applications/kdapps/kaspa-auth/scripts/set-storage-mode.sh keychain
# or
bash applications/kdapps/kaspa-auth/scripts/set-storage-mode.sh dev
```

Verify:

```
systemctl --user status kaspa-auth.service --no-pager
~/.cargo/bin/kaspa-auth daemon status --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock"
~/.cargo/bin/kaspa-auth daemon send --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock" ping
```

