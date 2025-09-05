#!/usr/bin/env bash
set -euo pipefail

THEME_NAME="kaspax"

print() { echo -e "[kaspax-sddm] $*"; }

if [[ ${EUID:-$(id -u)} -eq 0 ]]; then
  print "Do not run as root; the script will sudo when needed."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SRC_DIR="$REPO_ROOT/themes/kaspax/sddm"
if [[ ! -d "$SRC_DIR" ]]; then
  echo "Theme source not found: $SRC_DIR" >&2
  exit 1
fi

THEME_DST="/usr/share/sddm/themes/${THEME_NAME}"
CONF_DIR="/etc/sddm.conf.d"
CONF_FILE="$CONF_DIR/10-${THEME_NAME}.conf"
WS_SESS_DIR="/usr/share/wayland-sessions"
HYPR_DESKTOP_SRC="$REPO_ROOT/new-hyprland-config/hyprland.desktop"
HYPR_DESKTOP_DST="$WS_SESS_DIR/hyprland.desktop"

print "Installing SDDM theme to $THEME_DST ..."
sudo install -d -m 0755 "$THEME_DST"
sudo cp -a "$SRC_DIR/." "$THEME_DST/"

print "Ensuring SDDM config directory exists: $CONF_DIR"
sudo install -d -m 0755 "$CONF_DIR"

print "Setting SDDM theme to '$THEME_NAME' in $CONF_FILE"
sudo tee "$CONF_FILE" >/dev/null <<EOF
[Theme]
Current=${THEME_NAME}
EOF

if [[ -f "$HYPR_DESKTOP_SRC" ]]; then
  print "Installing Hyprland Wayland session: $HYPR_DESKTOP_DST"
  sudo install -d -m 0755 "$WS_SESS_DIR"
  sudo install -m 0644 "$HYPR_DESKTOP_SRC" "$HYPR_DESKTOP_DST"
fi

print "Done. Reboot or restart SDDM to see the theme."
print "To test without reboot: sudo systemctl restart sddm (on a TTY)"

