#!/usr/bin/env bash
set -euo pipefail

# Import an existing dev-mode private key into the OS keychain so that the
# same address is preserved when switching to keychain mode.
#
# Requirements:
#   - secret-tool (libsecret) and an unlocked keyring (e.g., gnome-keyring)
#   - dev key file at $KASPA_AUTH_DATA_DIR/.kaspa-auth/<username>.key
#   - kaspa-auth binary to verify after import
#
# Usage:
#   import-dev-key-to-keychain.sh --username participant-peer

USERNAME=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    -u|--username)
      USERNAME="$2"; shift 2;;
    *) echo "Unknown arg: $1" >&2; exit 1;;
  esac
done

if [ -z "$USERNAME" ]; then
  echo "Usage: $0 --username <name>" >&2
  exit 1
fi

CLI_BIN="${CLI_BIN:-$HOME/.cargo/bin/kaspa-auth}"
DATA_DIR="${KASPA_AUTH_DATA_DIR:-$HOME/.local/share/kaspa-auth}"
DEV_KEY_FILE="$DATA_DIR/.kaspa-auth/${USERNAME}.key"

if ! command -v secret-tool >/dev/null 2>&1; then
  echo "secret-tool not found (install libsecret)." >&2
  exit 1
fi

if [ ! -f "$DEV_KEY_FILE" ]; then
  echo "Dev key file not found: $DEV_KEY_FILE" >&2
  echo "Make sure you ran dev mode first, or create a wallet:"
  echo "  $CLI_BIN --dev-mode wallet-status --username $USERNAME --create"
  exit 1
fi

PRIV_HEX="$(tr -d '\n\r ' < "$DEV_KEY_FILE")"
if ! [[ "$PRIV_HEX" =~ ^[0-9a-fA-F]{64}$ ]]; then
  echo "Key file doesn't look like a 32-byte hex key: $DEV_KEY_FILE" >&2
  exit 1
fi

echo "[import-dev-key] Storing key in keychain for service=kaspa-auth username=$USERNAME"
# Store under org.freedesktop.Secret.Generic with attributes service/username
printf '%s' "$PRIV_HEX" | secret-tool store --label "kaspa-auth/$USERNAME" service kaspa-auth username "$USERNAME"

echo "[import-dev-key] Verifying with kaspa-auth --keychain"
if [ -x "$CLI_BIN" ]; then
  KASPA_AUTH_DATA_DIR="$DATA_DIR" "$CLI_BIN" --keychain wallet-status --username "$USERNAME" >/dev/null 2>&1 || true
  "$CLI_BIN" --keychain wallet-status --username "$USERNAME" | sed -n '1,6p'
else
  echo "kaspa-auth binary not found at $CLI_BIN; skipping CLI verification"
fi

echo "[import-dev-key] Done. You can now switch the service to keychain mode."

