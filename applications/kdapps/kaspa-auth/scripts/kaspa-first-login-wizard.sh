#!/usr/bin/env bash
set -euo pipefail

# First login flow:
# - Ensure kaspa-auth user service running
# - Ensure a keychain-backed wallet exists
# - Show splash (address + QR) in default browser
# - Write a marker to avoid reruns via autostart

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SHOW_SPLASH="$SCRIPT_DIR/show-wizard-splash.sh"

MARKER_DIR="$HOME/.local/share/kaspa-auth"
MARKER_FILE="$MARKER_DIR/.first_login_done"
SOCKET_PATH="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/kaspa-auth.sock"
BIN_PATH="$HOME/.cargo/bin/kaspa-auth"
USERNAME="participant-peer"
export KASPA_AUTH_DATA_DIR="$HOME/.local/share/kaspa-auth"

# Storage mode toggle via env: set KASPAX_USE_KEYCHAIN=1 to use keychain
MODE_FLAGS="--dev-mode"
if [ "${KASPAX_USE_KEYCHAIN:-0}" = "1" ]; then
  MODE_FLAGS="--keychain"
fi

FORCE=false
if [ "${1-}" = "--force" ] || [ "${2-}" = "--force" ]; then
  FORCE=true
fi

log() { printf "[kaspa-first-login] %s\n" "$*"; }

# Guard: run once unless forced
if [ -f "$MARKER_FILE" ] && [ "$FORCE" = false ]; then
  log "Marker exists: $MARKER_FILE — skipping (use --force to re-run)."
  exit 0
fi

# Ensure service is installed and running (best-effort)
log "Starting kaspa-auth.service"
systemctl --user start kaspa-auth.service || true

# Wait briefly for the socket (best-effort)
for i in {1..20}; do
  [ -S "$SOCKET_PATH" ] && break
  sleep 0.2
done

# Ensure the CLI exists
if [ ! -x "$BIN_PATH" ]; then
  echo "Error: kaspa-auth binary not found at $BIN_PATH" >&2
  echo "Install it: cargo install --path examples/kaspa-auth --bin kaspa-auth" >&2
  exit 1
fi

if [ "$MODE_FLAGS" = "--keychain" ]; then
  log "Ensuring keychain wallet for user: $USERNAME"
else
  log "Ensuring dev-mode wallet for user: $USERNAME (file-based)"
fi
mkdir -p "$KASPA_AUTH_DATA_DIR" || true
WALLET_OUT="$($BIN_PATH $MODE_FLAGS wallet-status --username "$USERNAME" --create 2>/dev/null || true)"

# Try to extract an address line
ADDR=$(printf "%s\n" "$WALLET_OUT" | grep -iE "Kaspa Address" | head -n1 | sed -E 's/.*:[[:space:]]*//')

if [ -z "${ADDR:-}" ]; then
  # Fallback: last token on last non-empty line
  ADDR=$(printf "%s\n" "$WALLET_OUT" | awk 'NF{last=$0} END{print last}' | awk '{print $NF}')
fi

if [ -z "${ADDR:-}" ]; then
  echo "Error: could not determine wallet address from output:" >&2
  printf "%s\n" "$WALLET_OUT" >&2
  exit 1
fi

log "Wallet address: $ADDR"

if [ ! -x "$SHOW_SPLASH" ]; then
  chmod +x "$SHOW_SPLASH" || true
fi

"$SHOW_SPLASH" "$ADDR" || true

mkdir -p "$MARKER_DIR"
date +%s > "$MARKER_FILE"
log "Wrote marker: $MARKER_FILE"

log "Done. You can re-run with --force if needed."
