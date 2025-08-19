#!/usr/bin/env bash
set -euo pipefail

# Toggle storage mode between dev (file) and keychain.
# - Updates the local unit file ExecStart to pass either --dev-mode or --keychain
# - Installs the unit to ~/.config/systemd/user and restarts the service
# - Leaves scripts able to honor KASPAX_USE_KEYCHAIN=1 as an override

usage() {
  echo "Usage: $0 <dev|keychain>" >&2
  exit 1
}

MODE="${1-}"
case "$MODE" in
  dev|keychain) ;;
  *) usage ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
UNIT_SRC="$APP_ROOT/systemd/kaspa-auth.service"
UNIT_TMP="$(mktemp)"
UNIT_DST="$HOME/.config/systemd/user/kaspa-auth.service"

if [ ! -f "$UNIT_SRC" ]; then
  echo "Error: unit file not found: $UNIT_SRC" >&2
  exit 1
fi

FLAG="--dev-mode"
[ "$MODE" = keychain ] && FLAG="--keychain"

# Rewrite ExecStart: remove any existing mode flag, then insert the desired one
awk -v FLAG="$FLAG" '
  /^ExecStart=/ {
    gsub(/ --dev-mode/, "");
    gsub(/ --keychain/, "");
    sub(/kaspa-auth/, "kaspa-auth " FLAG);
  }
  { print }
' "$UNIT_SRC" > "$UNIT_TMP"

install -m 0644 "$UNIT_TMP" "$UNIT_SRC"
mkdir -p "$(dirname "$UNIT_DST")"
install -m 0644 "$UNIT_TMP" "$UNIT_DST"
rm -f "$UNIT_TMP"

mkdir -p "$HOME/.local/share/kaspa-auth"

echo "[set-storage-mode] Installed unit in $UNIT_DST (mode: $MODE)" >&2
systemctl --user daemon-reload
systemctl --user enable --now kaspa-auth.service || true
systemctl --user restart kaspa-auth.service || true
systemctl --user status kaspa-auth.service --no-pager -l || true

echo "Tip: export KASPAX_USE_KEYCHAIN=1 to force scripts to use keychain mode." >&2

