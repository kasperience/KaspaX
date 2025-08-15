# Installing Kaspa Linux with Hyprland and SDDM

This guide will help you install Kaspa Linux using our clean Hyprland+SDDM setup.

## Prerequisites

1. A fresh Arch Linux installation
2. Internet access
3. Basic understanding of the command line

## Installation Steps

### 1. Update your system

```bash
sudo pacman -Syu
```

### 2. Install git if not already installed

```bash
sudo pacman -S git
```

### 3. Clone the Kaspa Linux repository

```bash
git clone https://github.com/kaspa-linux/kaspa-linux.git ~/kaspa-linux
cd ~/kaspa-linux/examples/kaspa-linux/kaspax/hyprland-sddm-config
```

### 4. Run the installation script

```bash
./install/install.sh
```

This script will:
- Install all required packages (Hyprland, SDDM, Waybar, etc.)
- Copy configuration files to the appropriate locations
- Enable SDDM as the display manager
- Enable NetworkManager for network connectivity

### 5. Build and install Kaspa applications

```bash
./install/install-kaspa-apps.sh
```

This script will:
- Build the kaspa-auth and kdapp-wallet applications
- Install them to `~/.local/share/kdapps/`
- Install systemd service files
- Reload systemd user services

### 6. Reboot your system

```bash
sudo reboot
```

After rebooting, you should see the SDDM login screen. Log in with your credentials, and Hyprland should start automatically.

## Post-Installation

### Starting the kaspa-auth daemon

After logging in, start the kaspa-auth daemon:

```bash
systemctl --user enable --now kaspa-auth
```

### Verifying the installation

Check the status of the kaspa-auth daemon:

```bash
systemctl --user status kaspa-auth
```

View the logs:

```bash
journalctl --user -u kaspa-auth -f
```

## Customization

You can customize the desktop environment by modifying the configuration files in `~/.config/`:

- `~/.config/hypr/` - Hyprland configuration
- `~/.config/waybar/` - Waybar configuration
- `~/.config/mako/` - Notification daemon configuration
- `~/.config/swayosd/` - OSD configuration

## Troubleshooting

### SDDM not starting

If SDDM doesn't start after reboot:

```bash
sudo systemctl enable sddm
sudo systemctl start sddm
```

### Hyprland not starting

If Hyprland doesn't start after login, check the logs:

```bash
cat ~/.xsession-errors
```

### Kaspa applications not working

If the Kaspa applications are not working, verify they were built and installed correctly:

```bash
ls -la ~/.local/share/kdapps/
```

You should see the kaspa-auth and kdapp-wallet directories with the respective binaries.