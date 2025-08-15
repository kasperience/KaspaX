#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Function to print status messages
print_status() {
    echo -e "\n\e[1;34m$1\e[0m"
}

# Function to print error messages
print_error() {
    echo -e "\n\e[1;31m$1\e[0m"
}

# Function to print success messages
print_success() {
    echo -e "\n\e[1;32m$1\e[0m"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Update system
print_status "Updating system packages..."
sudo pacman -Syu --noconfirm

# Install required packages
print_status "Installing required packages..."
sudo pacman -S --noconfirm \
    hyprland \
    sddm \
    kitty \
    waybar \
    mako \
    swaybg \
    swayosd \
    walker \
    polkit-gnome \
    firefox \
    thunar \
    pulseaudio \
    pavucontrol \
    networkmanager \
    brightnessctl \
    grim \
    slurp \
    wlogout \
    wf-recorder \
    swaylock \
    rofi \
    clipman \
    qt5-wayland \
    qt6-wayland \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    ttf-jetbrains-mono-nerd \
    wl-clipboard \
    wl-clip-persist

# Create necessary directories
print_status "Creating configuration directories..."
mkdir -p ~/.config/{hypr,waybar,mako,swayosd,backgrounds,clipman,rofi,swaylock}

# Copy configuration files
print_status "Copying configuration files..."
cp -r /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/hyprland-sddm-config/config/hypr/* ~/.config/hypr/
cp -r /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/hyprland-sddm-config/config/waybar/* ~/.config/waybar/
cp -r /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/hyprland-sddm-config/config/mako/* ~/.config/mako/
cp -r /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/hyprland-sddm-config/config/swayosd/* ~/.config/swayosd/
cp -r /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/hyprland-sddm-config/config/clipman/* ~/.config/clipman/
cp -r /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/hyprland-sddm-config/config/rofi/* ~/.config/rofi/
cp -r /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/hyprland-sddm-config/config/swaylock/* ~/.config/swaylock/

# Create a default background directory
mkdir -p ~/.config/backgrounds

# Enable SDDM
print_status "Enabling SDDM..."
sudo systemctl enable sddm

# Enable NetworkManager
print_status "Enabling NetworkManager..."
sudo systemctl enable NetworkManager

# Install Kaspa applications
print_status "Installing Kaspa applications..."
mkdir -p ~/.local/share/kdapps/

# Copy kaspa-auth if it exists
if [ -d "/mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/applications/kdapps/kaspa-auth" ]; then
    print_status "Installing kaspa-auth..."
    mkdir -p ~/.local/share/kdapps/kaspa-auth
    # We'll need to build it later
fi

# Copy kdapp-wallet if it exists
if [ -d "/mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/applications/kdapps/kdapp-wallet" ]; then
    print_status "Installing kdapp-wallet..."
    mkdir -p ~/.local/share/kdapps/kdapp-wallet
    # We'll need to build it later
fi

# Create systemd user services directory
mkdir -p ~/.config/systemd/user

# Create a basic user session configuration
print_status "Creating user session configuration..."
cat > ~/.profile << EOF
# Basic environment variables
export XDG_CURRENT_DESKTOP=Hyprland
export XDG_SESSION_DESKTOP=Hyprland
export XDG_SESSION_TYPE=wayland
export GDK_BACKEND=wayland,x11
export QT_QPA_PLATFORM=wayland
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export SDL_VIDEODRIVER=wayland
export CLUTTER_BACKEND=wayland
EOF

# Print success message
print_success "Installation completed successfully!"

echo "
-------------------------------------------------------------------------------
Next steps:
1. Reboot your system to start SDDM
2. After login, Hyprland should start automatically
3. To build and install Kaspa applications, navigate to their respective directories and run:
   cargo build --release
   cp target/release/<binary-name> ~/.local/share/kdapps/<app-name>/
4. Enable systemd user services for Kaspa applications:
   systemctl --user enable --now <service-name>
-------------------------------------------------------------------------------
"