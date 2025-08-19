#!/usr/bin/env bash
set -euo pipefail

echo "Installing LM Studio (Arch)…"

if command -v yay >/dev/null 2>&1; then
  yay -S --noconfirm --needed lm-studio-bin || {
    echo "AUR install failed. Consider AppImage: https://lmstudio.ai/download"
    exit 1
  }
  echo "LM Studio installed via AUR."
else
  echo "No AUR helper detected. Please download AppImage from https://lmstudio.ai/download"
  echo "Example:"
  echo "  mkdir -p ~/Applications && cd ~/Applications"
  echo "  wget <AppImage URL> -O LMStudio.AppImage && chmod +x LMStudio.AppImage"
  echo "  ./LMStudio.AppImage"
fi

