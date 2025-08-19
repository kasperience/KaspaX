#!/usr/bin/env bash
set -euo pipefail

# Installs and enables the kaspa-auth user service.
# - Copies the unit into ~/.config/systemd/user/
# - daemon-reload, enable, and start

echo "[kaspa-auth] Installing systemd user service" >&2

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
UNIT_SRC="$APP_ROOT/systemd/kaspa-auth.service"
UNIT_DST="$HOME/.config/systemd/user/kaspa-auth.service"

if [ ! -f "$UNIT_SRC" ]; then
  echo "Error: unit file not found at $UNIT_SRC" >&2
  exit 1
fi

mkdir -p "$(dirname "$UNIT_DST")"
install -m 0644 "$UNIT_SRC" "$UNIT_DST"

# Ensure data directory exists to satisfy ReadWritePaths and daemon data-dir
mkdir -p "$HOME/.local/share/kaspa-auth"

echo "[kaspa-auth] Reloading user units" >&2
systemctl --user daemon-reload

echo "[kaspa-auth] Enabling and starting service" >&2
systemctl --user enable --now kaspa-auth.service

echo "[kaspa-auth] Service state:" >&2
systemctl --user --no-pager status kaspa-auth.service || true

echo "[kaspa-auth] Done. Logs: journalctl --user -u kaspa-auth -f" >&2
