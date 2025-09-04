#!/usr/bin/env bash
set -euo pipefail

# Switch between Hyprland theme profiles: pretty | performance
# Copies the chosen profile into ~/.config/hypr/kaspax.conf and prints reload hints.

PROFILE="${1:-pretty}"
if [[ "$PROFILE" != "pretty" && "$PROFILE" != "performance" ]]; then
  echo "Usage: $0 [pretty|performance]" >&2
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
HYPR_CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
mkdir -p "$HYPR_CFG_DIR"

SRC_PRETTY="$ROOT_DIR/themes/kaspax/hyprland.conf"
SRC_PERF="$ROOT_DIR/themes/kaspax/hyprland.performance.conf"
DST="$HYPR_CFG_DIR/kaspax.conf"

case "$PROFILE" in
  pretty)      cp -a "$SRC_PRETTY" "$DST" ;;
  performance) cp -a "$SRC_PERF"   "$DST" ;;
esac

echo "[KaspaX] Installed $PROFILE profile to $DST"
echo "Reload suggestions: hyprctl reload"

