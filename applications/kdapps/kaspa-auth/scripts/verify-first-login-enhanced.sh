#!/usr/bin/env bash
set -euo pipefail

# Runs the standard verifier, then provides extra hints if duplicate
# storage flags are detected in the user unit ExecStart.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"${SCRIPT_DIR}/verify-first-login.sh" "${@:-}" || true

UNIT_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/kaspa-auth.service"
if [[ -f "$UNIT_PATH" ]]; then
  if grep -qE '^ExecStart=.*--keychain.*--keychain' "$UNIT_PATH" || grep -qE '^ExecStart=.*--dev-mode.*--dev-mode' "$UNIT_PATH"; then
    echo "[verify-first-login] ⚠️ Detected duplicate storage flag in unit ExecStart"
    sed -n '/^ExecStart/p' "$UNIT_PATH" || true
    echo "[verify-first-login] Hint: run the repair tool:"
    echo "[verify-first-login]   bash applications/kdapps/kaspa-auth/scripts/repair-user-unit.sh"
    echo "[verify-first-login]   systemctl --user reset-failed kaspa-auth.service && systemctl --user restart kaspa-auth.service"
  fi
fi

exit 0

