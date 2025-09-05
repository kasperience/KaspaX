#!/usr/bin/env bash
set -euo pipefail

# Install and enable the kaspa-auth user service.

CLI_BIN="${CLI_BIN:-$HOME/.cargo/bin/kaspa-auth}"
UNIT_SRC="$(cd "$(dirname "$0")"/.. && pwd)/systemd/kaspa-auth.service"
UNIT_TARGET_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
UNIT_TARGET="$UNIT_TARGET_DIR/kaspa-auth.service"

echo "[install-systemd] Preparing directories..."
mkdir -p "$UNIT_TARGET_DIR"
mkdir -p "$HOME/.local/share/kaspa-auth"

if [ ! -x "$CLI_BIN" ]; then
  echo "[install-systemd] Warning: kaspa-auth binary not found at $CLI_BIN"
  echo "  Build it with: cargo install --path applications/kdapps/kaspa-auth --bin kaspa-auth"
fi

echo "[install-systemd] Installing unit: $UNIT_TARGET"
cp -f "$UNIT_SRC" "$UNIT_TARGET"

echo "[install-systemd] Reloading systemd (user)..."
systemctl --user daemon-reload

echo "[install-systemd] Enabling and starting service..."
systemctl --user enable --now kaspa-auth.service

echo "[install-systemd] Done. Socket should appear at: $XDG_RUNTIME_DIR/kaspa-auth.sock"
echo "View logs: journalctl --user -u kaspa-auth -f"

