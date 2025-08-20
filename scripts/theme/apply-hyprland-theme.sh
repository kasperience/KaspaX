#!/usr/bin/env bash
set -euo pipefail

# Apply KaspaX theme to Hyprland (and optional Waybar)
# - Generates wallpaper for current resolution
# - Writes hyprpaper.conf to use the KaspaX wallpaper
# - Installs a Hyprland theme fragment and sources it from hyprland.conf (with backup)
# - Optionally installs Waybar CSS

confirm() { read -r -p "$1 [y/N] " _r; [[ "${_r:-}" =~ ^[Yy]$ ]]; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

HYPR_CFG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
WAYBAR_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"

mkdir -p "$HYPR_CFG_DIR" "$WAYBAR_DIR"

# 1) Detect resolution
RES=""
if command -v hyprctl >/dev/null 2>&1; then
  # Try to parse first monitor resolution via hyprctl
  RES=$(hyprctl -j monitors 2>/dev/null | sed -n 's/.*"width":\([0-9]\+\).*"height":\([0-9]\+\).*/\1x\2/p' | head -n1 || true)
fi
RES="${RES:-1920x1080}"

echo "[KaspaX] Using resolution: $RES"

# 2) Generate wallpaper
bash "$ROOT_DIR/scripts/theme/render-wallpaper.sh" "$RES"

W=${RES%x*}; H=${RES#*x}
WALL_PATH="${XDG_DATA_HOME:-$HOME/.local/share}/kaspax/wallpapers/kaspax-${W}x${H}.png"

# 3) hyprpaper.conf
HP_CONF="$HYPR_CFG_DIR/hyprpaper.conf"
cat > "$HP_CONF" <<EOF
preload = $WALL_PATH
wallpaper = , $WALL_PATH
EOF
echo "[KaspaX] Wrote hyprpaper config: $HP_CONF"

# 4) Hyprland theme fragment
THEME_SRC="$ROOT_DIR/themes/kaspax/hyprland.conf"
THEME_DST="$HYPR_CFG_DIR/kaspax.conf"
install -m 0644 "$THEME_SRC" "$THEME_DST"
echo "[KaspaX] Installed Hyprland theme fragment: $THEME_DST"

HYPR_MAIN="$HYPR_CFG_DIR/hyprland.conf"
if [ -f "$HYPR_MAIN" ] && ! grep -q "^source *= *$THEME_DST" "$HYPR_MAIN"; then
  cp -a "$HYPR_MAIN" "$HYPR_MAIN.bak" && echo "[KaspaX] Backed up $HYPR_MAIN to $HYPR_MAIN.bak"
  printf "\n# KaspaX theme\nsource = %s\n" "$THEME_DST" >> "$HYPR_MAIN"
  echo "[KaspaX] Appended source line to $HYPR_MAIN"
elif [ ! -f "$HYPR_MAIN" ]; then
  printf "# Hyprland base config\n\n# KaspaX theme\nsource = %s\n" "$THEME_DST" > "$HYPR_MAIN"
  echo "[KaspaX] Created $HYPR_MAIN with theme source"
fi

# 5) Waybar theme (optional)
WB_STYLE_SRC="$ROOT_DIR/themes/kaspax/waybar.css"
WB_STYLE_DST="$WAYBAR_DIR/style.css"
if confirm "Install Waybar style to $WB_STYLE_DST?"; then
  if [ -f "$WB_STYLE_DST" ]; then cp -a "$WB_STYLE_DST" "$WB_STYLE_DST.bak" && echo "[KaspaX] Backed up $WB_STYLE_DST"; fi
  install -m 0644 "$WB_STYLE_SRC" "$WB_STYLE_DST"
  echo "[KaspaX] Installed Waybar style"
fi

echo
echo "[KaspaX] Done. Reload suggestions:"
echo "  - hyprctl reload"
echo "  - pkill hyprpaper; hyprpaper & disown"
echo "  - systemctl --user restart waybar (if you run it as a user service)"
