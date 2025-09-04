#!/bin/bash

# Exit on errors, unset variables, and pipe failures
set -euo pipefail

KASPA_LINUX_INSTALL=~/.local/share/kaspa-linux/install

# Give people a chance to retry running the installation
catch_errors() {
  echo -e "\n\e[31mKaspa Linux installation failed!\e[0m"
  echo "You can retry by running: bash ~/.local/share/kaspa-linux/install.sh"
  echo "Get help from the community: https://discord.gg/kaspa"
}

trap catch_errors ERR

show_logo() {
  clear
  tte -i ~/.local/share/kaspa-linux/logo.txt --frame-rate ${2:-120} ${1:-expand}
  echo
}

show_subtext() {
  echo "$1" | tte --frame-rate ${3:-640} ${2:-wipe}
  echo
}

# Install prerequisites
source $KASPA_LINUX_INSTALL/preflight/aur.sh
source $KASPA_LINUX_INSTALL/preflight/presentation.sh

# Configuration
show_logo beams 240
show_subtext "Let's install Kaspa Linux! [1/4]"
source $KASPA_LINUX_INSTALL/config/identification.sh
source $KASPA_LINUX_INSTALL/config/config.sh
source $KASPA_LINUX_INSTALL/config/detect-keyboard-layout.sh
source $KASPA_LINUX_INSTALL/config/fix-fkeys.sh
source $KASPA_LINUX_INSTALL/config/network.sh
source $KASPA_LINUX_INSTALL/config/power.sh
source $KASPA_LINUX_INSTALL/config/timezones.sh
source $KASPA_LINUX_INSTALL/config/login.sh
source $KASPA_LINUX_INSTALL/config/nvidia.sh

# Development
show_logo decrypt 920
show_subtext "Installing terminal tools [2/4]"
source $KASPA_LINUX_INSTALL/development/terminal.sh
source $KASPA_LINUX_INSTALL/development/development.sh
source $KASPA_LINUX_INSTALL/development/nvim.sh
source $KASPA_LINUX_INSTALL/development/docker.sh
source $KASPA_LINUX_INSTALL/development/firewall.sh

# Desktop
show_logo slice 60
show_subtext "Installing desktop tools [3/4]"
source $KASPA_LINUX_INSTALL/desktop/desktop.sh
source $KASPA_LINUX_INSTALL/desktop/theme.sh
source $KASPA_LINUX_INSTALL/desktop/bluetooth.sh
source $KASPA_LINUX_INSTALL/desktop/fonts.sh
source $KASPA_LINUX_INSTALL/desktop/printer.sh

# Apps
show_logo expand
show_subtext "Installing default applications [4/4]"
source $KASPA_LINUX_INSTALL/apps/kaspa-apps.sh
source $KASPA_LINUX_INSTALL/apps/xtras.sh
source $KASPA_LINUX_INSTALL/apps/mimetypes.sh

# Updates
show_logo highlight
show_subtext "Updating system packages"
sudo updatedb
sudo pacman -Syu --noconfirm

# Reboot
show_logo laseretch 920
show_subtext "You're done! So we'll be rebooting now..."
sleep 2
reboot
