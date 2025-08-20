#!/usr/bin/env bash
set -euo pipefail

# Toggle Waybar style between default and neon for KaspaX
# Usage:
#   ./toggle-waybar-style.sh neon
#   ./toggle-waybar-style.sh default

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
TARGET="${1:-}"

if [[ -z "$TARGET" || ! "$TARGET" =~ ^(neon|default)$ ]]; then
  echo "Usage: $0 <neon|default>" >&2
  exit 1
fi

STYLE_DIR="$ROOT_DIR/themes/kaspax"
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
DEST_CSS="$DEST_DIR/style.css"
mkdir -p "$DEST_DIR"

case "$TARGET" in
  neon)
    SRC="$STYLE_DIR/waybar.neon.css"
    ;;
  default)
    SRC="$STYLE_DIR/waybar.css"
    ;;
esac

if [ ! -f "$SRC" ]; then
  echo "Source style not found: $SRC" >&2
  exit 1
fi

if [ -f "$DEST_CSS" ]; then
  cp -a "$DEST_CSS" "$DEST_CSS.bak" || true
fi

install -m 0644 "$SRC" "$DEST_CSS"
echo "[KaspaX] Applied Waybar style: $TARGET -> $DEST_CSS"

# Reload Waybar if running
if pgrep -x waybar >/dev/null 2>&1; then
  pkill -USR2 waybar || true
fi

