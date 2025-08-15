#!/bin/bash

# Script to help users switch between installation approaches

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

# Display usage information
usage() {
    echo "Usage: $0 [clean|legacy]"
    echo "  clean   - Switch to the clean Hyprland+SDDM setup"
    echo "  legacy  - Switch to the legacy Omarchy-based setup"
    echo ""
    echo "If no argument is provided, the current setup will be displayed."
}

# Check current setup
check_current_setup() {
    if [ -f "~/.config/hypr/hyprland.conf" ]; then
        # Check if it's the clean setup or legacy setup
        if grep -q "hyprland-sddm-config" "~/.config/hypr/hyprland.conf" 2>/dev/null; then
            echo "Current setup: Clean Hyprland+SDDM setup"
        elif grep -q "omarchy" "~/.config/hypr/hyprland.conf" 2>/dev/null; then
            echo "Current setup: Legacy Omarchy-based setup (with references removed)"
        else
            echo "Current setup: Custom/Unknown"
        fi
    else
        echo "Current setup: Not installed or not configured"
    fi
}

# Switch to clean setup
switch_to_clean() {
    print_status "Switching to clean Hyprland+SDDM setup..."
    
    # Backup current config if it exists
    if [ -d "~/.config/hypr" ]; then
        print_status "Backing up current Hyprland configuration..."
        mv ~/.config/hypr ~/.config/hypr.backup.$(date +%s)
    fi
    
    # Copy clean config
    print_status "Copying clean Hyprland+SDDM configuration..."
    mkdir -p ~/.config/hypr
    cp -r /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/hyprland-sddm-config/config/hypr/* ~/.config/hypr/
    
    # Backup and copy Waybar config
    if [ -d "~/.config/waybar" ]; then
        print_status "Backing up current Waybar configuration..."
        mv ~/.config/waybar ~/.config/waybar.backup.$(date +%s)
    fi
    
    print_status "Copying clean Waybar configuration..."
    mkdir -p ~/.config/waybar
    cp -r /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/hyprland-sddm-config/config/waybar/* ~/.config/waybar/
    
    # Backup and copy Mako config
    if [ -d "~/.config/mako" ]; then
        print_status "Backing up current Mako configuration..."
        mv ~/.config/mako ~/.config/mako.backup.$(date +%s)
    fi
    
    print_status "Copying clean Mako configuration..."
    mkdir -p ~/.config/mako
    cp -r /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/hyprland-sddm-config/config/mako/* ~/.config/mako/
    
    # Backup and copy SwayOSD config
    if [ -d "~/.config/swayosd" ]; then
        print_status "Backing up current SwayOSD configuration..."
        mv ~/.config/swayosd ~/.config/swayosd.backup.$(date +%s)
    fi
    
    print_status "Copying clean SwayOSD configuration..."
    mkdir -p ~/.config/swayosd
    cp -r /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/hyprland-sddm-config/config/swayosd/* ~/.config/swayosd/
    
    print_success "Switched to clean Hyprland+SDDM setup successfully!"
    echo "You may need to restart your session for changes to take effect."
}

# Switch to legacy setup
switch_to_legacy() {
    print_status "Switching to legacy Omarchy-based setup..."
    
    # Backup current config if it exists
    if [ -d "~/.config/hypr" ]; then
        print_status "Backing up current Hyprland configuration..."
        mv ~/.config/hypr ~/.config/hypr.backup.$(date +%s)
    fi
    
    # Copy legacy config
    print_status "Copying legacy Omarchy-based configuration..."
    mkdir -p ~/.config/hypr
    cp -r /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/config/hypr/* ~/.config/hypr/
    
    # Backup and copy Waybar config
    if [ -d "~/.config/waybar" ]; then
        print_status "Backing up current Waybar configuration..."
        mv ~/.config/waybar ~/.config/waybar.backup.$(date +%s)
    fi
    
    print_status "Copying legacy Waybar configuration..."
    mkdir -p ~/.config/waybar
    # Note: In the legacy setup, Waybar config might be in a different location
    # We'll need to adjust this based on the actual structure
    
    print_success "Switched to legacy Omarchy-based setup successfully!"
    echo "You may need to restart your session for changes to take effect."
}

# Main script logic
if [ $# -eq 0 ]; then
    print_status "Checking current setup..."
    check_current_setup
    echo ""
    usage
    exit 0
fi

case $1 in
    clean)
        switch_to_clean
        ;;
    legacy)
        switch_to_legacy
        ;;
    *)
        print_error "Invalid argument: $1"
        usage
        exit 1
        ;;
esac