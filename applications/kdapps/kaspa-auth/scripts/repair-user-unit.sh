#!/usr/bin/env bash
set -euo pipefail

# repair-user-unit.sh
# Normalizes the user unit ExecStart to ensure a single storage-mode flag
# and restarts the kaspa-auth user service.

UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
UNIT_PATH="$UNIT_DIR/kaspa-auth.service"

if [[ ! -f "$UNIT_PATH" ]]; then
  echo "[repair-user-unit] No user unit found at $UNIT_PATH" >&2
  exit 1
fi

# Collapse accidental duplicate mode flags if present
sed -E -i 's/--keychain[[:space:]]+--keychain/--keychain/g' "$UNIT_PATH" || true
sed -E -i 's/--dev-mode[[:space:]]+--dev-mode/--dev-mode/g' "$UNIT_PATH" || true

# Extra guard: ensure that we do not have both --dev-mode and --keychain simultaneously
if grep -qE 'ExecStart=.*--dev-mode.*--keychain|ExecStart=.*--keychain.*--dev-mode' "$UNIT_PATH"; then
  echo "[repair-user-unit] Found both --dev-mode and --keychain. Keeping --keychain for keychain mode." >&2
  sed -E -i 's/--dev-mode[[:space:]]+//g' "$UNIT_PATH"
fi

if grep -q -- '--keychain' "$UNIT_PATH"; then
  count=$(grep -c -- '--keychain' "$UNIT_PATH")
  if [[ "$count" -ne 1 ]]; then
    echo "[repair-user-unit] Expected exactly one --keychain flag in $UNIT_PATH, found $count" >&2
    exit 1
  fi
fi
if grep -q -- '--dev-mode' "$UNIT_PATH"; then
  count=$(grep -c -- '--dev-mode' "$UNIT_PATH")
  if [[ "$count" -ne 1 ]]; then
    echo "[repair-user-unit] Expected exactly one --dev-mode flag in $UNIT_PATH, found $count" >&2
    exit 1
  fi
fi

echo "[repair-user-unit] Repaired unit flags in $UNIT_PATH"
systemctl --user daemon-reload
systemctl --user restart kaspa-auth.service || true
systemctl --user status kaspa-auth.service --no-pager || true

echo "[repair-user-unit] Done. If the service still fails, run:\n  journalctl --user -u kaspa-auth.service -b --no-pager | tail -n 200" >&2

