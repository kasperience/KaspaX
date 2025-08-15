# Kaspa Linux

A decentralized Linux distribution built on Arch Linux with Hyprland, specifically designed for the Kaspa ecosystem. This system provides a fully-configured environment with native support for Kaspa blockchain applications and peer-to-peer technologies.

## Vision

Kaspa Linux is built around three core principles:

1. **Decentralization:** Native support for decentralized technologies with all core applications functioning on a peer-to-peer basis.
2. **User Sovereignty:** Users have ultimate control over their data, identity, and interactions without reliance on centralized services.
3. **Kaspa Ecosystem:** Purpose-built as a premier platform for developing and using applications within the Kaspa ecosystem.

## Key Technologies

* **Operating System Base:** Arch Linux + Hyprland + SDDM
* **Core Application Framework:** kdapp (Rust-based P2P framework)
* **Blockchain Integration:** Native integration with the Kaspa network for identity, data, and transactions.

## Core Integrated Applications

* **kaspa-auth:** A decentralized identity and authentication service
* **kdapp-wallet:** A persistent wallet service for managing Kaspa assets
* **comment-it / comment-board:** Natively integrated commenting and discussion platforms

## Installation Approaches

We provide two different installation approaches:

### 1. Hyprland+SDDM Clean Setup (Recommended)

A minimal, clean setup using Hyprland as the window manager and SDDM as the display manager.

**Location:** `hyprland-sddm-config` directory

**Features:**
- Minimal bloatware
- Clean configuration files
- Easy customization
- Native Hyprland+SDDM setup
- Uses standard Linux tools (rofi, swaylock, clipman, etc.)
- No Omarchy-specific applications

**Installation:**
See `hyprland-sddm-config/INSTALL.md` for detailed installation instructions.

### 2. Legacy Omarchy-based Setup

A more feature-rich setup based on the Omarchy framework (with all Omarchy references removed).

**Location:** Root directory

**Features:**
- More comprehensive desktop environment
- Additional applications and tools
- More complex configuration

**Installation:**
See `DEPLOYMENT.md` for detailed installation instructions.

## License

Kaspa Linux is released under the [MIT License](https://opensource.org/licenses/MIT).

