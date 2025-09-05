# Waybar — Double Instance Troubleshooting (KaspaX)

This guide helps you resolve “two Waybars” showing at once. The usual cause is that two different launch methods start Waybar.

## Symptom
- Two bars visible at the top/bottom; `pgrep -a waybar` shows two PIDs.

## Common Causes
- Hyprland `exec-once = waybar` and a systemd user unit both start Waybar.
- A leftover autostart `.desktop` (rare) also starts Waybar.

## Choose ONE Launch Method

### Option A — Hyprland manages Waybar (recommended)
1) Disable the user unit and kill extras:
```
systemctl --user disable --now waybar.service || true
systemctl --user reset-failed waybar.service || true
systemctl --user mask waybar.service  # prevent accidental starts
pkill waybar
```
2) Ensure only a single exec in Hyprland config:
```
grep -R -nE '^\s*exec.*waybar' ~/.config/hypr 2>/dev/null
```
Keep one line like:
```
exec-once = waybar
```
3) Reload/start:
```
hyprctl reload
# If it didn’t start automatically:
waybar >/dev/null 2>&1 & disown
```
4) Verify there is only one process:
```
pgrep -a waybar
```

### Option B — systemd user unit manages Waybar
1) Remove Waybar from Hyprland config (keep hyprpaper if present):
```
sed -i 's/^exec-once = .*waybar.*$/exec-once = hyprpaper/' ~/.config/hypr/hyprland.conf
hyprctl reload
```
2) Ensure Wayland env in systemd and start the unit:
```
systemctl --user import-environment DISPLAY WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
systemctl --user enable --now waybar.service
```
3) Verify:
```
pgrep -a waybar
systemctl --user status waybar --no-pager -l
```

## Quick Diagnostics
- Who is launching Waybar?
```
grep -R -nE '^\s*exec.*waybar' ~/.config/hypr 2>/dev/null
systemctl --user is-enabled waybar.service || true
systemctl --user is-active waybar.service || true
pgrep -a waybar
```
- If Waybar is not running and you use systemd (Option B):
```
systemctl --user unmask waybar.service 2>/dev/null || true
systemctl --user enable --now waybar.service
```
- If Waybar is not running and you use Hyprland (Option A):
```
waybar >/dev/null 2>&1 & disown
```
- Stop duplicates immediately:
```
pkill waybar
```
- Reload Waybar after CSS changes (no restart needed):
```
pkill -USR2 waybar
```

## KaspaX Helpers
- Switch launch method safely and reload Hyprland:
```
bash scripts/theme/switch-waybar-management.sh systemd   # or: hyprland
```
- Included user unit (if you prefer systemd):
  - `hyprland-sddm-config/config/systemd/user/waybar.service`
  - Install/enable:
    - `install -m 0644 hyprland-sddm-config/config/systemd/user/waybar.service ~/.config/systemd/user/`
    - `systemctl --user daemon-reload && systemctl --user enable --now waybar.service`

## Notes
- Prefer one launch path to avoid race conditions and duplicates.
- If you choose Hyprland, consider masking the unit (`systemctl --user mask waybar.service`).
- If you choose systemd, make sure no `exec-once = waybar` remains in any included Hyprland file.
 - If you previously masked the unit and now want systemd to manage Waybar again, unmask first:
```
systemctl --user unmask waybar.service
systemctl --user enable --now waybar.service
```
