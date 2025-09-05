# KaspaX SDDM Theme (Arch + Hyprland)

This installs a simple, dark SDDM greeter themed for KaspaX.

## Files
- Theme: `themes/kaspax/sddm/` (QML + assets)
- Installer: `hyprland-sddm-config/install/install-kaspax-sddm-theme.sh`
- Hyprland session file (if missing): `new-hyprland-config/hyprland.desktop`

## Install
```
# From repo root
bash hyprland-sddm-config/install/install-kaspax-sddm-theme.sh
```
What it does:
- Copies theme → `/usr/share/sddm/themes/kaspax`
- Writes `/etc/sddm.conf.d/10-kaspax.conf` with:
```
[Theme]
Current=kaspax
```
- Ensures `hyprland.desktop` exists under `/usr/share/wayland-sessions/`

## Verify
- `grep -R "Current=kaspax" /etc/sddm.conf* /etc/sddm.conf.d/*`
- Switch to a TTY (Ctrl+Alt+F3) and restart greeter:
```
sudo systemctl restart sddm
```
- Or reboot.

## Uninstall
```
sudo rm -rf /usr/share/sddm/themes/kaspax
sudo rm -f /etc/sddm.conf.d/10-kaspax.conf
```
Then set another theme in `/etc/sddm.conf` or `/etc/sddm.conf.d/`.

## Notes
- Keep this theming minimal to avoid breaking distro updates.
- For PAM keyring unlock, follow `KASPAX_FIRST_LOGIN.md` (SDDM section).
- SDDM runs as root; theme assets must be world-readable.

