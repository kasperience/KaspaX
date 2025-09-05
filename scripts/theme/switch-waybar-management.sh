#!/usr/bin/env bash
set -euo pipefail

# Switch Waybar startup between Hyprland exec-once and a user systemd unit.
# Usage: switch-waybar-management.sh systemd|hyprland

MODE="${1:-}"
if [[ -z "$MODE" || ! "$MODE" =~ ^(systemd|hyprland)$ ]]; then
  echo "Usage: $0 <systemd|hyprland>" >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")"/../.. && pwd)"
HYPR_CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/hypr"
HYPR_MAIN="$HYPR_CONF_DIR/hyprland.conf"
UNIT_SRC="$ROOT_DIR/hyprland-sddm-config/config/systemd/user/waybar.service"
UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
UNIT_DST="$UNIT_DIR/waybar.service"

mkdir -p "$HYPR_CONF_DIR" "$UNIT_DIR"

backup_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  cp -a "$f" "$f.bak.$(date +%Y%m%d-%H%M%S)" || true
}

case "$MODE" in
  systemd)
    if [[ ! -f "$UNIT_SRC" ]]; then
      echo "Waybar unit template not found: $UNIT_SRC" >&2
      exit 1
    fi
    install -m 0644 "$UNIT_SRC" "$UNIT_DST"
    systemctl --user daemon-reload
    systemctl --user enable --now waybar.service || true

    if [[ -f "$HYPR_MAIN" ]]; then
      backup_file "$HYPR_MAIN"
      # Remove standalone waybar exec-once lines
      sed -i -E '/^\s*exec-once\s*=\s*waybar(\s.*)?$/d' "$HYPR_MAIN"
      # Replace combined hyprpaper & waybar with only hyprpaper
      sed -i -E 's/^(\s*exec-once\s*=\s*hyprpaper)\s*&\s*waybar/\1/g' "$HYPR_MAIN"
    fi
    echo "[KaspaX] Waybar now managed by systemd (user)."
    ;;

  hyprland)
    # Disable user unit if present
    systemctl --user disable --now waybar.service >/dev/null 2>&1 || true

    # Ensure Hyprland will start Waybar. Prefer appending a simple exec-once if none exists
    if [[ -f "$HYPR_MAIN" ]]; then
      backup_file "$HYPR_MAIN"
      if ! rg -q "^\s*exec-once\s*=.*waybar" "$HYPR_MAIN" 2>/dev/null; then
        printf "\n# Start Waybar at session start\nexec-once = waybar\n" >> "$HYPR_MAIN"
      fi
    else
      printf "# Hyprland base config\nexec-once = waybar\n" > "$HYPR_MAIN"
    fi
    echo "[KaspaX] Waybar now managed by Hyprland exec-once."
    ;;
esac

echo "Reloading Hyprland (if running)..."
hyprctl reload >/dev/null 2>&1 || true

echo "Done. If switching to systemd, you can manage Waybar with:\n  systemctl --user restart waybar\n  systemctl --user status waybar\n" 

