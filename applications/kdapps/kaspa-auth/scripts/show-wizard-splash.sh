#!/usr/bin/env bash
set -euo pipefail

# Render wizard splash HTML with wallet address and open via xdg-open.

ADDR="${1:-}"
if [ -z "$ADDR" ]; then
  echo "Usage: $0 <kaspa_address>" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/../public/wizard_splash.template.html"
LOGO_PATH="$(realpath "$SCRIPT_DIR/../public/assets/kdapp_framework.jpg")"
TMP_HTML="$(mktemp /tmp/kaspa-wizard-splash.XXXXXX.html)"

# Optional QR code generation
QR_IMG_TAG=""
if command -v qrencode >/dev/null 2>&1; then
  TMP_PNG="$(mktemp /tmp/kaspa-addr-qr.XXXXXX.png)"
  qrencode -o "$TMP_PNG" "$ADDR"
  QR_IMG_TAG="<img src=\"data:image/png;base64,$(base64 -w0 "$TMP_PNG")\" alt=\"Kaspa address QR code\" />"
  rm "$TMP_PNG"
fi

export LOGO_PATH KASPA_ADDRESS="$ADDR" KASPA_NETWORK="${KASPA_NETWORK:-testnet}" QR_IMG_TAG

envsubst < "$TEMPLATE" > "$TMP_HTML"

xdg-open "file://$TMP_HTML" >/dev/null 2>&1 &
