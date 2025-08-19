Optional installers for popular apps. These are not required by KaspaX but are commonly used alongside development flows.

- Ollama: local LLM runtime
  - `install-ollama.sh` (AUR `ollama-bin` if `yay` exists; otherwise prompts to run official install script)
- LM Studio: desktop UI for LLMs
  - `install-lm-studio.sh` (AUR `lm-studio-bin` if `yay`; otherwise AppImage instructions)
- Brave: browser
  - `install-brave.sh` (prefers pacman if available, falls back to AUR or Flatpak)

Notes:
- Scripts prompt where appropriate; review commands before confirming.
- AUR requires an AUR helper such as `yay`.
- Flatpak requires `flatpak` and Flathub remote configured.

