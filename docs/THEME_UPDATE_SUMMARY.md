# KaspaX Theme Update Summary

This document summarizes the new KaspaX theme set and key differences from the previous (tested) theme in `themes/kaspax_old`.

## Goals
- Align accents with official Kaspa colours.
- Improve readability and consistency across components.
- Keep motion and effects subtle; remain VM‑friendly.

## Colour Alignment
- Primary: `#70C7BA` (official Kaspa primary)
- Secondary: `#49EACB` (official Kaspa secondary)
- Neutral gray: `#B6B6B6`
- Dark neutral reference: `#231F20`

Derived tokens (for consistency and contrast):
- `--bg: #1A1D21`, `--surface: #21252B`, `--border: #2A2E35`, `--text: #E6E6E6`, `--muted: #9DA5B1`

## Component Changes
- Hyprland (`themes/kaspax/hyprland.conf`)
  - Active border: `#70C7BA`; inactive border: `#231F20` with transparency.
  - `border_size = 3`, mild blur/shadows, `vfr = true`.
  - Tip: On low‑end GPUs/VMs disable extras (blur/shadows) for performance.
- Waybar (`themes/kaspax/waybar.css`)
  - Uses derived `bg/surface/border/text/muted` tokens.
  - Accent: `#70C7BA` (primary). Clean, readable modules.
- Waybar Neon (`themes/kaspax/waybar.neon.css`)
  - Accent: `#49EACB` (secondary) with subtle glow.
- Palette (`themes/kaspax/palette.css`)
  - Centralises official colours and derived tokens.
- Hyprpaper
  - New: ships a ready `wallpaper.png` aligned with the palette.
  - Older example file `hyprpaper.conf.example` removed in new theme (our apply script generates config automatically).
- Extras
  - New theme now includes: `kitty.conf`, `rofi.rasi`, `mako.conf`, and `sddm/` folder for login theming.

## Adoption
- Apply the theme and wallpaper:
  - `examples/kaspa-linux/kaspax/scripts/theme/apply-hyprland-theme.sh`
- Toggle Waybar style:
  - `examples/kaspa-linux/kaspax/scripts/theme/toggle-waybar-style.sh neon`
  - `examples/kaspa-linux/kaspax/scripts/theme/toggle-waybar-style.sh default`
- Performance tips:
  - In `hyprland.conf` set `drop_shadow = no` and `blur { enabled = no }` if performance is constrained.

## Notes
- Background values are slightly deeper than `#231F20` to enhance text contrast in real‑world lighting.
- All colours reference the official Kaspa palette; accents and neutral align exactly.
