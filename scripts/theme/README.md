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
 - Output: `~/.local/share/kaspax/wallpapers/kaspax-<WxH>.png`

### Options: Teal Tint & Quote Overlay
- Teal tint (on by default):
```
KASPAX_TINT=0 ./render-wallpaper.sh 1920x1080            # disable tint
KASPAX_TINT_COLOR='#00ffd5' ./render-wallpaper.sh 1920x1080
KASPAX_TINT_ALPHA=5 ./render-wallpaper.sh 1920x1080      # lighter tint
```
- Quote overlay (auto-on if `themes/kaspax/quotes.txt` exists):
```
KASPAX_QUOTE=1 ./render-wallpaper.sh 1920x1080
KASPAX_QUOTES_FILE=/path/to/quotes.txt ./render-wallpaper.sh 1920x1080
KASPAX_QUOTE_COLOR='#9ad9c8' KASPAX_QUOTE_SIZE=28 KASPAX_QUOTE_MARGIN=64 ./render-wallpaper.sh 1920x1080
# Optional font (must be installed):
KASPAX_QUOTE_FONT='DejaVu-Sans' ./render-wallpaper.sh 1920x1080
```

After rendering, restart hyprpaper to reload the image:
```
pkill hyprpaper; hyprpaper >/dev/null 2>&1 & disown
```

### Milk-Glass Panel (Readable Area)
Add a frosted/milk-glass panel at the bottom center (blurred background with translucent white overlay) to improve text readability.
```
# Enable and render with defaults (80% width, 180px height):
KASPAX_GLASS=1 ./render-wallpaper.sh 1920x1080

# Tune size/position/opacity:
KASPAX_GLASS_WIDTH=0.75 KASPAX_GLASS_HEIGHT=200 KASPAX_GLASS_MARGIN=90 \
KASPAX_GLASS_RADIUS=28 KASPAX_GLASS_BLUR=12 KASPAX_GLASS_ALPHA=40 \
KASPAX_GLASS=1 ./render-wallpaper.sh 1920x1080
```
Render quotes after enabling glass to place text on top of the panel:
```
KASPAX_GLASS=1 KASPAX_QUOTE=1 ./render-wallpaper.sh 1920x1080
```

### Background Image (Hyprland/Cyberpunk)
Use any image as the wallpaper base, then apply teal tint, glass, logo, and quotes.
```
# Cover the canvas, crop to fill (recommended):
KASPAX_BG_IMAGE="$HOME/Pictures/wallpapers/cyberpunk.jpg" \
KASPAX_BG_MODE=cover \
./render-wallpaper.sh 1920x1080

# Keep full image visible with letterboxing:
KASPAX_BG_IMAGE="$HOME/Pictures/wallpapers/cyberpunk.jpg" \
KASPAX_BG_MODE=contain \
./render-wallpaper.sh 1920x1080

# Stretch to fit (may distort):
KASPAX_BG_IMAGE="$HOME/Pictures/wallpapers/cyberpunk.jpg" \
KASPAX_BG_MODE=stretch \
./render-wallpaper.sh 1920x1080
```

Combine everything (tint + full-width glass + logo + quote):
```
KASPAX_BG_IMAGE="$HOME/Pictures/wallpapers/cyberpunk.jpg" \
KASPAX_BG_MODE=cover \
KASPAX_TINT=1 KASPAX_TINT_ALPHA=8 \
KASPAX_GLASS=1 KASPAX_GLASS_WIDTH=1 KASPAX_GLASS_HEIGHT=1080 KASPAX_GLASS_MARGIN=0 \
KASPAX_GLASS_RADIUS=18 KASPAX_GLASS_BLUR=10 KASPAX_GLASS_ALPHA=10 \
KASPAX_QUOTE=1 \
./render-wallpaper.sh 1920x1080
```

<!-- Matrix overlay documentation intentionally removed to simplify visuals. -->

### Optional: Circular Logo + Ring
Control the logo shape and a teal ring around it:
```
# Default is circle with ring; switch to square:
KASPAX_LOGO_SHAPE=square ./render-wallpaper.sh 1920x1080

# Make the logo slightly smaller (e.g., 18% of width):
KASPAX_LOGO_SCALE=0.18 ./render-wallpaper.sh 1920x1080

# Soften the circle edge to avoid any hard boundary (in pixels):
KASPAX_LOGO_FEATHER=2 ./render-wallpaper.sh 1920x1080

# Customize ring (only for circle):
KASPAX_LOGO_RING=1 KASPAX_RING_COLOR='#00e5b0' KASPAX_RING_WIDTH=6 ./render-wallpaper.sh 1920x1080

# Disable ring:
KASPAX_LOGO_RING=0 ./render-wallpaper.sh 1920x1080
```

## Hyprpaper Example
- File: `../../themes/kaspax/hyprpaper.conf.example`
- Copy to `~/.config/hypr/hyprpaper.conf` and adjust resolution/path if needed.

## One-shot Theme Apply (Hyprland + Waybar)
- Script: `apply-hyprland-theme.sh`
- What it does:
  - Detects resolution and renders a KaspaX wallpaper.
  - Writes `~/.config/hypr/hyprpaper.conf` to use that wallpaper.
  - Installs `~/.config/hypr/kaspax.conf` and sources it from `hyprland.conf` (backup created).
  - Optionally installs Waybar CSS to `~/.config/waybar/style.css` (backup created).
- Run:
```
./apply-hyprland-theme.sh
```
- Reload after applying:
```
hyprctl reload
pkill hyprpaper; hyprpaper >/dev/null 2>&1 & disown
# If running Waybar as a user service:
systemctl --user restart waybar.service || true
```

## Troubleshooting: Two Waybars
If you see two Waybars, you likely have both Hyprland (exec-once) and a systemd user unit launching Waybar. See:
- docs/WAYBAR_TROUBLESHOOTING.md

Quick recover tips:
- If you use systemd to manage Waybar and it’s not running:
```
systemctl --user unmask waybar.service 2>/dev/null || true
systemctl --user enable --now waybar.service
```
- If you use Hyprland to manage Waybar:
```
waybar >/dev/null 2>&1 & disown
```

## Switch Waybar Style (Default ⇄ Neon)
Toggle between the standard KaspaX Waybar style and a brighter neon variant:
```
scripts/theme/toggle-waybar-style.sh neon
scripts/theme/toggle-waybar-style.sh default
```
The script copies the style into `~/.config/waybar/style.css` and signals Waybar to reload.
