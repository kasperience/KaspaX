#!/bin/bash
# Script to apply the Kaspa theme manually

echo "Applying Kaspa theme..."

# Define source and destination directories
SOURCE_DIR="$HOME/.config/kaspa-linux/themes/omarchy-kaspa-theme"
CONFIG_DIR="$HOME/.config"

# Apply Alacritty theme
mkdir -p "$CONFIG_DIR/alacritty"
cp "$SOURCE_DIR/alacritty.toml" "$CONFIG_DIR/alacritty/"

# Apply Neovim theme
mkdir -p "$CONFIG_DIR/nvim/colors"
cp "$SOURCE_DIR/neovim.lua" "$CONFIG_DIR/nvim/colors/kaspa.lua"

# Apply Waybar theme
mkdir -p "$CONFIG_DIR/waybar"
cp "$SOURCE_DIR/waybar.css" "$CONFIG_DIR/waybar/"

# Apply btop theme
mkdir -p "$CONFIG_DIR/btop/themes"
cp "$SOURCE_DIR/btop.theme" "$CONFIG_DIR/btop/themes/kaspa.theme"

# Apply mako theme
mkdir -p "$CONFIG_DIR/mako"
cp "$SOURCE_DIR/mako.ini" "$CONFIG_DIR/mako/config"

# Apply hyprland theme
# Note: This would typically be merged with existing hyprland.conf
# cp "$SOURCE_DIR/hyprland.conf" "$CONFIG_DIR/hyprland/"

# Apply hyprlock theme
mkdir -p "$CONFIG_DIR/hyprlock"
cp "$SOURCE_DIR/hyprlock.conf" "$CONFIG_DIR/hyprlock/"

# Apply walker theme
mkdir -p "$CONFIG_DIR/walker"
cp "$SOURCE_DIR/walker.css" "$CONFIG_DIR/walker/style.css"

# Apply swayosd theme
mkdir -p "$CONFIG_DIR/swayosd"
cp "$SOURCE_DIR/swayosd.css" "$CONFIG_DIR/swayosd/style.css"

echo "Kaspa theme applied successfully!"
echo "Please restart your applications or log out and back in for all changes to take effect."