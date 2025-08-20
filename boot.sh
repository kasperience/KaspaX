#!/bin/bash

ansi_art='                 ▄▄▄                                                   
 ▄█████▄    ▄███████████▄    ▄███████   ▄███████   ▄███████   ▄█   █▄    ▄█   █▄ 
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   ███  ███   ███  ███   ███
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   █▀   ███   ███  ███   ███
███   ███  ███   ███   ███ ▄███▄▄▄███ ▄███▄▄▄██▀  ███       ▄███▄▄▄███▄ ███▄▄▄███
███   ███  ███   ███   ███ ▀███▀▀▀███ ▀███▀▀▀▀    ███      ▀▀███▀▀▀███  ▀▀▀▀▀▀███
███   ███  ███   ███   ███  ███   ███ ██████████  ███   █▄   ███   ███  ▄██   ███
███   ███  ███   ███   ███  ███   ███  ███   ███  ███   ███  ███   ███  ███   ███
 ▀█████▀    ▀█   ███   █▀   ███   █▀   ███   ███  ███████▀   ███   █▀    ▀█████▀ 
                                       ███   █▀                                  '

clear
echo -e "\n$ansi_art\n"

sudo pacman -Sy --noconfirm --needed git

# Use custom repo if specified, otherwise default to kaspa-linux
KASPA_LINUX_REPO="${KASPA_LINUX_REPO:-kaspa-linux/kaspa-linux}"

echo -e "\nCloning Kaspa Linux from: https://github.com/${KASPA_LINUX_REPO}.git"
rm -rf ~/.local/share/kaspa-linux/
git clone "https://github.com/${KASPA_LINUX_REPO}.git" ~/.local/share/kaspa-linux >/dev/null

# Use custom branch if instructed
if [[ -n "$KASPA_LINUX_REF" ]]; then
  echo -e "\eUsing branch: $KASPA_LINUX_REF"
  cd ~/.local/share/kaspa-linux
  git fetch origin "${KASPA_LINUX_REF}" && git checkout "${KASPA_LINUX_REF}"
  cd -
fi

echo -e "\nInstallation starting..."
source ~/.local/share/kaspa-linux/install.sh
