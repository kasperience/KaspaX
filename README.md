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

## Development Environment

Choose between a fast CLI-focused dev loop or a full desktop:

- WSL2 (Ubuntu or ArchWSL): Best for coding and running CLI examples without a desktop. Install Rust with `rustup` inside WSL and work entirely within the Linux filesystem (avoid Windows-mounted paths for cargo targets). Systemd user services are limited; prefer the VM if you need them.
- Arch Linux VM (full Kaspa Linux): Install a minimal Arch VM, then run our installers to overlay Hyprland + SDDM and kdapps. This provides systemd user services, theming, and the intended desktop experience.

See `docs/DEV_ENV_SETUP.md` for step‑by‑step guidance, VM sizing, networking tips, keychain setup, and update workflow.

## Theme Update

We refreshed the KaspaX theme to align accents and neutrals with the official Kaspa palette and improve readability. See `docs/THEME_UPDATE_SUMMARY.md` for a summary and adoption tips.

## License

Kaspa Linux is released under the [MIT License](https://opensource.org/licenses/MIT).
