# Arch + Hyprland + Kaspa Auth Environment

This repository contains the configuration for a minimal, fast, and secure Arch Linux environment using the Hyprland Wayland compositor. It is pre-configured to run the `kaspa-auth` daemon for decentralized authentication.

## Core Components

*   **Window Compositor:** [Hyprland](https://hyprland.org/)
*   **Login Manager:** [SDDM](https://github.com/sddm/sddm)
*   **Authentication Daemon:** [kaspa-auth](https://github.com/kaspanet/kaspad) (via a user-level systemd service)
*   **Status Bar:** Waybar
*   **Notification Daemon:** Mako
*   **Application Launcher:** Wofi

## Installation & Setup

These instructions assume you are on a fresh Arch Linux installation with a GPU driver.

1.  **Install Core Packages:**

    ```bash
    sudo pacman -S hyprland sddm waybar wofi alacritty thunar gnome-keyring seahorse polkit-gnome
    ```

2.  **Copy Configuration Files:**

    *   Copy `hyprland.conf` to `~/.config/hypr/`.
    *   Copy `hyprland.desktop` to `/usr/share/xsessions/` (requires sudo).
    *   Copy `kaspa-auth.service` to `~/.config/systemd/user/`.

    ```bash
    # From the root of this repository
    mkdir -p ~/.config/hypr
    mkdir -p ~/.config/systemd/user

    cp new-hyprland-config/hyprland.conf ~/.config/hypr/
    cp config/systemd/user/kaspa-auth.service ~/.config/systemd/user/
    sudo cp new-hyprland-config/hyprland.desktop /usr/share/xsessions/
    ```

3.  **Install the `kaspa-auth` Binary:**

    Build your `kaspa-auth` project and place the final binary at `~/.local/share/kdapps/kaspa-auth/kaspa-auth`.

    ```bash
    # Example build and copy command (run from your kaspa-auth project directory)
    cargo build --release
    mkdir -p ~/.local/share/kdapps/kaspa-auth
    cp target/release/kaspa-auth ~/.local/share/kdapps/kaspa-auth/
    ```

4.  **Enable SDDM:**

    ```bash
    sudo systemctl enable sddm
    ```

5.  **Reboot:**

    After rebooting, select the "Hyprland" session from the SDDM login screen.

## How It Works

Upon logging in, the `hyprland.conf` script is executed. It performs the following key actions:

*   Starts the `gnome-keyring-daemon` to manage secrets.
*   Uses `systemctl --user` to enable and start the `kaspa-auth.service` daemon.
*   Launches essential desktop components like Waybar, Mako, and the Polkit agent.

This setup ensures that the `kaspa-auth` daemon is running and ready to be used by your other `kdapps` in a clean, standard Arch Linux environment.
