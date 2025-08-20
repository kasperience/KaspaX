#!/usr/bin/env bash
set -euo pipefail

# Show a simple GUI splash (address + QR) in the default browser.
# - Generates a temporary HTML file and QR image (if qrencode is available).
# - Uses the kdapp framework logo from the repo for branding.
#
# Usage: show-wizard-splash.sh <kaspa_address>
# Env:
#   KASPA_NETWORK=testnet|mainnet (default: testnet)

if [ "${1-}" = "" ]; then
  echo "Usage: $0 <kaspa_address>" >&2
  exit 1
fi

ADDR="$1"

# Resolve paths relative to this script inside the kaspax repo
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ASSETS_DIR="$APP_ROOT/public/assets"
LOGO_PATH="$ASSETS_DIR/kdapp_framework.jpg"
TEMPLATE="$APP_ROOT/public/wizard_splash.template.html"
PALETTE_CSS="$APP_ROOT/../../../themes/kaspax/palette.css"

TMP_DIR="$(mktemp -d 2>/dev/null || mktemp -d -t kaspa-wizard)"
HTML_OUT="$TMP_DIR/wizard_splash.html"
QR_IMG="$TMP_DIR/qr.png"

# Determine network + prefix for address URI
NETWORK="${KASPA_NETWORK:-testnet}"
PREFIX="kaspa"
NETWORK_LABEL=""
if [ "$NETWORK" = "testnet" ]; then
  PREFIX="kaspatest"
  NETWORK_LABEL="testnet"
else
  PREFIX="kaspa"
  NETWORK_LABEL="mainnet"
fi
PREF_ADDR="${PREFIX}:${ADDR}"

# Explorer URL per network (use raw address in path; add network query for testnet)
if [ "$NETWORK" = "testnet" ]; then
  EXPLORER_URL="https://explorer.kaspa.org/addresses/${ADDR}?network=testnet-10"
else
  EXPLORER_URL="https://explorer.kaspa.org/addresses/${ADDR}"
fi

# Try to generate a QR code if qrencode is available (use prefixed URI)
QR_STATUS="missing"
if command -v qrencode >/dev/null 2>&1; then
  qrencode -o "$QR_IMG" -s 9 -m 2 "$PREF_ADDR" && QR_STATUS="ok" || QR_STATUS="fail"
fi

# Build HTML from template (fallback to a minimal inline doc if template missing)
if [ -f "$TEMPLATE" ]; then
  # Faucet block only on testnet
  if [ "$NETWORK" = "testnet" ]; then
    FAUCET_HTML='Testnet faucet: <a href="https://faucet.kaspanet.io/">faucet.kaspanet.io</a>'
  else
    FAUCET_HTML=''
  fi

  sed \
    -e "s#__ADDRESS__#${PREF_ADDR//\/\\}#g" \
    -e "s#__LOGO_PATH__#${LOGO_PATH//\/\\}#g" \
    -e "s#__QR_PATH__#${QR_IMG//\/\\}#g" \
    -e "s#__QR_STATUS__#${QR_STATUS}#g" \
    -e "s#__PALETTE_CSS__#${PALETTE_CSS//\/\\}#g" \
    -e "s#__NETWORK_LABEL__#${NETWORK_LABEL}#g" \
    -e "s#__FAUCET_BLOCK__#${FAUCET_HTML//\/\\}#g" \
    -e "s#__EXPLORER_URL__#${EXPLORER_URL//\/\\}#g" \
    "$TEMPLATE" > "$HTML_OUT"
else
  cat > "$HTML_OUT" <<EOF
<!doctype html>
<html lang="en"><meta charset="utf-8"><title>Kaspa Auth – First Login</title>
<body style="font-family: system-ui, Arial; background:#0F1115; color:#EAEAEA; display:grid; place-items:center; height:100vh; margin:0;">
  <div style="max-width:720px; padding:24px; background:#151821; border:1px solid #25293a; border-radius:16px; box-shadow:0 10px 30px rgba(0,0,0,.5);">
    <div style="display:flex; gap:16px; align-items:center; margin-bottom:12px;">
      <img src="file://$LOGO_PATH" alt="kdapp" style="height:56px; border-radius:8px;">
      <h1 style="margin:0; font-size:22px;">Kaspa Auth – First Login</h1>
    </div>
    <p style="opacity:.85;">Welcome! Fund your wallet, then proceed with authentication flows.</p>
    <div style="display:flex; gap:24px; margin-top:16px; align-items:center;">
      <div>
        <div style="font-size:13px; opacity:.7;">Kaspa address <span style=\"font-size:12px; opacity:.75;\">$NETWORK_LABEL</span></div>
        <code style="display:block; user-select:all; font-size:15px; background:#0d0f14; padding:12px; border-radius:8px; border:1px solid #25293a;">$PREF_ADDR</code>
        $( [ "$NETWORK" = "testnet" ] && echo '<div style="margin-top:8px; font-size:13px; opacity:.7;">Testnet faucet: <a href="https://faucet.kaspanet.io/" style="color:#6ce5a3">faucet.kaspanet.io</a></div>' )
        <div style="margin-top:12px; display:flex; gap:12px;">
          <a href="$EXPLORER_URL" target="_blank" style="text-decoration:none;" class="btn">Open in explorer</a>
        </div>
      </div>
      <div>
        <div style="font-size:13px; opacity:.7; margin-bottom:8px;">QR code</div>
        <div style="width:256px; height:256px; display:grid; place-items:center; background:#0d0f14; border-radius:12px; border:1px solid #25293a;">
          <!-- QR unavailable without qrencode; install it to enable -->
          <div style="font-size:12px; opacity:.6; text-align:center; padding:12px;">Install <code>qrencode</code> to render QR locally.</div>
        </div>
      </div>
    </div>
  </div>
</body></html>
EOF
fi

# Open in default browser
if command -v xdg-open >/dev/null 2>&1; then
  xdg-open "file://$HTML_OUT" >/dev/null 2>&1 & disown || true
else
  printf "Splash page: %s\n" "$HTML_OUT"
fi

echo "Opened wizard splash at: $HTML_OUT"
