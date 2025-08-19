#!/bin/bash
set -euo pipefail

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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Repo root is one level up from hyprland-sddm-config
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
APPS_DIR="$REPO_ROOT/applications/kdapps"

# Build and install kaspa-auth
if [ -d "$APPS_DIR/kaspa-auth" ]; then
    print_status "Building kaspa-auth (workspace)..."
    (
        cd "$APPS_DIR"
        cargo build --release -p kaspa-auth
    )

    print_status "Installing kaspa-auth..."
    mkdir -p "$HOME/.local/share/kdapps/kaspa-auth"
    cp "$APPS_DIR/target/release/kaspa-auth" "$HOME/.local/share/kdapps/kaspa-auth/"
    print_success "kaspa-auth installed successfully!"
else
    print_error "kaspa-auth directory not found at $APPS_DIR/kaspa-auth"
fi

# Build and install kdapp-wallet
if [ -d "$APPS_DIR/kdapp-wallet" ]; then
    print_status "Building kdapp-wallet (workspace)..."
    (
        cd "$APPS_DIR"
        cargo build --release -p kdapp-wallet
    )

    print_status "Installing kdapp-wallet..."
    mkdir -p "$HOME/.local/share/kdapps/kdapp-wallet"
    cp "$APPS_DIR/target/release/kdapp-wallet" "$HOME/.local/share/kdapps/kdapp-wallet/"
    print_success "kdapp-wallet installed successfully!"
else
    print_error "kdapp-wallet directory not found at $APPS_DIR/kdapp-wallet"
fi

# Install systemd service files
print_status "Installing systemd service files..."
mkdir -p "$HOME/.config/systemd/user"
cp "$REPO_ROOT/hyprland-sddm-config/config/systemd/user/kaspa-auth.service" "$HOME/.config/systemd/user/"

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
