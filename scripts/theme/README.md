# Kaspax Theme & Wallpapers

This folder provides a shared color palette and a script to render dark wallpapers with a centered kdapp logo.

## Palette (CSS)
- File: `../../themes/kaspax/palette.css`
- Usage in HTML:
  - `<link rel="stylesheet" href="../../themes/kaspax/palette.css" />`
  - Then use CSS variables like `var(--bg)`, `var(--accent)`.

## Wallpaper Generator
- Script: `render-wallpaper.sh`
- Requirements: ImageMagick (`pacman -S imagemagick`)
- Generate a wallpaper (default 1920x1080):
```
./render-wallpaper.sh
./render-wallpaper.sh 2560x1440
```
- Output: `~/.local/share/kaspax/wallpapers/kaspax-<WxH>.png`

## Hyprpaper Example
- File: `../../themes/kaspax/hyprpaper.conf.example`
- Copy to `~/.config/hypr/hyprpaper.conf` and adjust resolution/path if needed.

