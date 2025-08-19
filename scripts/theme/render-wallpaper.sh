#!/usr/bin/env bash
set -euo pipefail

# Generate a dark wallpaper with a centered kdapp logo using ImageMagick.
# Usage: render-wallpaper.sh [WIDTHxHEIGHT]
# Example: render-wallpaper.sh 1920x1080

RES="${1:-1920x1080}"
W=${RES%x*}
H=${RES#*x}

if ! [[ "$W" =~ ^[0-9]+$ && "$H" =~ ^[0-9]+$ ]]; then
  echo "Invalid resolution: $RES (expected e.g. 1920x1080)" >&2
  exit 1
fi

# Locate logo (from kaspa-auth assets)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOGO="$ROOT_DIR/applications/kdapps/kaspa-auth/public/assets/kdapp_framework.jpg"
if [ ! -f "$LOGO" ]; then
  echo "Logo not found: $LOGO" >&2
  exit 1
fi

# Output location
OUT_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/kaspax/wallpapers"
mkdir -p "$OUT_DIR"
OUT="$OUT_DIR/kaspax-${W}x${H}.png"

# Pick ImageMagick executable
IM="magick"
if ! command -v "$IM" >/dev/null 2>&1; then
  IM="convert"
fi
if ! command -v "$IM" >/dev/null 2>&1; then
  echo "ImageMagick not found. Install 'imagemagick' (pacman -S imagemagick)." >&2
  exit 1
fi

# Colors (match palette)
BG="#0F1115"

# Compute logo width as ~20% of screen width
LOGO_W=$(( W / 5 ))

# Render in a single pipeline
"$IM" -size ${W}x${H} xc:"$BG" \
  "(" "$LOGO" -resize ${LOGO_W}x "-gravity" center ")" \
  -gravity center -composite "$OUT"

echo "Wallpaper written: $OUT"

