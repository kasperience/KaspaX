# Kaspa Linux with Hyprland and SDDM

A clean, minimal setup for Kaspa Linux using Hyprland as the window manager and SDDM as the display manager.

## Overview

This setup provides a lightweight, customizable environment specifically designed for the Kaspa ecosystem with:

- Hyprland as the window manager
- SDDM as the display manager
- Native support for Kaspa applications (kaspa-auth, kdapp-wallet, etc.)
- Minimal bloatware
- Easy customization

## Directory Structure

```
hyprland-sddm-config/
├── README.md              # Overview of the clean setup
├── INSTALL.md             # Detailed installation instructions
├── SUMMARY.md             # Summary of changes made to the project
├── config/                # Configuration files
│   ├── hypr/              # Hyprland configuration
│   ├── waybar/            # Waybar configuration
│   ├── mako/              # Mako notification daemon configuration
│   ├── swayosd/          # SwayOSD configuration
│   ├── sddm/             # SDDM configuration
│   └── systemd/user/     # Systemd user service files
├── install/               # Installation scripts
│   ├── install.sh         # Main installation script
│   └── install-kaspa-apps.sh  # Script to build and install Kaspa applications
└── applications/          # Desktop entries
    └── hyprland.desktop   # Desktop entry for Hyprland
```

## Installation

1. Install the required packages:
   ```bash
   sudo pacman -S hyprland sddm waybar mako swaybg swayosd walker
   ```

2. Copy the configuration files:
   ```bash
   cp -r config/* ~/.config/
   ```

3. Enable SDDM:
   ```bash
   sudo systemctl enable sddm
   ```

## Configuration

The configuration is organized in a modular way:

- `config/hypr/` - Hyprland configuration files
- `config/waybar/` - Waybar configuration
- `config/mako/` - Notification daemon configuration
- `config/swayosd/` - OSD configuration

## License

Kaspa Linux is released under the [MIT License](https://opensource.org/licenses/MIT).