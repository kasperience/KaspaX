#!/usr/bin/env bash
set -euo pipefail

echo "Installing Brave Browser (Arch)…"

if command -v pacman >/dev/null 2>&1 && pacman -Si brave-browser >/dev/null 2>&1; then
  sudo pacman -S --needed brave-browser
  exit 0
fi

if command -v yay >/dev/null 2>&1; then
  yay -S --noconfirm --needed brave-bin
  exit 0
fi

if command -v flatpak >/dev/null 2>&1; then
  echo "Installing Brave from Flathub…"
  flatpak install -y flathub com.brave.Browser
  exit 0
fi

echo "No package source found. Options:"
echo "- Install via AUR: yay -S brave-bin"
echo "- Install via Flatpak: flatpak install flathub com.brave.Browser"
echo "- Or use Chromium/Firefox via pacman"
exit 1

