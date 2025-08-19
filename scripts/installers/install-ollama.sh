#!/usr/bin/env bash
set -euo pipefail

echo "Installing Ollama (Arch)…"

if command -v yay >/dev/null 2>&1; then
  yay -S --noconfirm --needed ollama-bin
else
  echo "No AUR helper (yay) detected. Using official install script."
  echo "Review the script at https://ollama.com; proceed? (y/N)"
  read -r ans
  if [[ "$ans" =~ ^[Yy]$ ]]; then
    curl -fsSL https://ollama.com/install.sh | sh
  else
    echo "Aborted. Install manually: https://ollama.com"
    exit 1
  fi
fi

echo "Ollama installed. Start with: systemctl --user start ollama (or run 'ollama serve')."

