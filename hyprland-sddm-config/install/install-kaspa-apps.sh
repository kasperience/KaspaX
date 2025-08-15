#!/bin/bash

# Script to build and install Kaspa applications

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

# Check if rust is installed
if ! command -v cargo &> /dev/null; then
    print_error "Rust is not installed. Please install it first with:"
    echo "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"
    exit 1
fi

# Build and install kaspa-auth
if [ -d "/mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/applications/kdapps/kaspa-auth" ]; then
    print_status "Building kaspa-auth..."
    cd /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/applications/kdapps/kaspa-auth
    cargo build --release
    
    if [ $? -eq 0 ]; then
        print_status "Installing kaspa-auth..."
        mkdir -p ~/.local/share/kdapps/kaspa-auth
        cp target/release/kaspa-auth ~/.local/share/kdapps/kaspa-auth/
        print_success "kaspa-auth installed successfully!"
    else
        print_error "Failed to build kaspa-auth"
    fi
else
    print_error "kaspa-auth directory not found"
fi

# Build and install kdapp-wallet
if [ -d "/mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/applications/kdapps/kdapp-wallet" ]; then
    print_status "Building kdapp-wallet..."
    cd /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/applications/kdapps/kdapp-wallet
    cargo build --release
    
    if [ $? -eq 0 ]; then
        print_status "Installing kdapp-wallet..."
        mkdir -p ~/.local/share/kdapps/kdapp-wallet
        cp target/release/kdapp-wallet ~/.local/share/kdapps/kdapp-wallet/
        print_success "kdapp-wallet installed successfully!"
    else
        print_error "Failed to build kdapp-wallet"
    fi
else
    print_error "kdapp-wallet directory not found"
fi

# Install systemd service files
print_status "Installing systemd service files..."
mkdir -p ~/.config/systemd/user
cp /mnt/c/Users/mariu/Documents/kdapp/kdapp/examples/kaspa-linux/kaspax/hyprland-sddm-config/config/systemd/user/kaspa-auth.service ~/.config/systemd/user/

# Reload systemd user services
print_status "Reloading systemd user services..."
systemctl --user daemon-reload

print_success "All Kaspa applications installed successfully!"

echo "
-------------------------------------------------------------------------------
To start the kaspa-auth daemon:
systemctl --user enable --now kaspa-auth

To check the status of the kaspa-auth daemon:
systemctl --user status kaspa-auth

To view logs:
journalctl --user -u kaspa-auth -f
-------------------------------------------------------------------------------
"