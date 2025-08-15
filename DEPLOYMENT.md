### Kaspa Linux on Omarchy: Deploy and Test kaspa-auth

This guide explains how to pull your fork on an already installed Omarchy system, deploy the `kaspa-auth` daemon, enable it as a user service, and test end-to-end. It also covers applying the Kaspa theme.

#### Prerequisites
- An installed Omarchy system (user session)
- Network access and `yay`
- Rust toolchain if building locally: `rustup` (optional if you ship binaries)
- Keychain services for secrets: `gnome-keyring libsecret seahorse`

```bash
yay -S --needed gnome-keyring libsecret seahorse
```

### 1) Point the installed Omarchy to your fork and update
By default, Omarchy lives at `~/.local/share/omarchy` on the installed system.

```bash
# Replace with your fork URL (SSH or HTTPS)
git -C ~/.local/share/omarchy remote set-url origin <your-fork-url>

# Pull latest changes and run migrations
~/.local/share/omarchy/bin/omarchy-update

# NOTE: Omarchy ships the Hyprland aggregator. Do not overwrite it.
# Keep ~/.config/hypr/hyprland.conf sourcing defaults and theme:
#   source = ~/.local/share/omarchy/default/hypr/... (multiple)
#   source = ~/.config/omarchy/current/theme/hyprland.conf
```

If you have local changes in that tree, commit or discard them before pulling.

### 2) Build and install the kaspa-auth binary (manual deployment)
If you have not added a migration that installs the binary automatically, build and place it under `~/.local/share/kdapps/kaspa-auth/`:

```bash
mkdir -p ~/.local/share/kdapps/kaspa-auth
cd ~/.local/share/omarchy/examples/kaspa-linux/omarchy/applications/kdapps/kaspa-auth
cargo build --release
install -Dm755 target/release/kaspa-auth ~/.local/share/kdapps/kaspa-auth/kaspa-auth
```

Tip: You can automate these steps later via a migration script in `migrations/`.

### 3) Enable the kaspa-auth systemd user service
The service unit is provided by the repo: `config/systemd/user/kaspa-auth.service`.

```bash
mkdir -p ~/.config/systemd/user
cp ~/.local/share/omarchy/config/systemd/user/kaspa-auth.service ~/.config/systemd/user/
systemctl --user daemon-reload
systemctl --user enable --now kaspa-auth

# Verify
systemctl --user status kaspa-auth
journalctl --user -u kaspa-auth -f
```

Notes
- The unit starts `%h/.local/share/kdapps/kaspa-auth/kaspa-auth --keychain daemon start --foreground` and uses your `XDG_RUNTIME_DIR`.
- Ensure `gnome-keyring-daemon` is running in your session so the keyring-backed storage works.

### 4) Create/unlock an authentication identity via the daemon
With the service running, use the same binary to send commands to the daemon over its socket.

```bash
# Create a new identity (stored via OS keychain)
~/.local/share/kdapps/kaspa-auth/kaspa-auth daemon send create --username alice --password 'secure123'

# Unlock when needed
~/.local/share/kdapps/kaspa-auth/kaspa-auth daemon send unlock --username alice --password 'secure123'

# Check status
~/.local/share/kdapps/kaspa-auth/kaspa-auth daemon send status
```

You can then perform your authentication flow against your organizer peer as usual.

### 5) Apply the Kaspa theme (optional)
If your theme is in a separate repo, install and select it:

```bash
# Install a theme repo; the tool places it under ~/.config/omarchy/themes/
~/.local/share/omarchy/bin/omarchy-theme-install <theme-git-url>

# Set theme by name (case/space-insensitive)
~/.local/share/omarchy/bin/omarchy-theme-set kaspa

# List available themes
~/.local/share/omarchy/bin/omarchy-theme-list
```

If your theme already exists under `~/.config/omarchy/themes/`, just run `omarchy-theme-set`.

### 6) Updating later

```bash
~/.local/share/omarchy/bin/omarchy-update
```

This pulls from your fork, runs any new migrations, refreshes configs, and offers to update system packages.

### Troubleshooting
- Service not found: re-copy the unit to `~/.config/systemd/user/` and `daemon-reload`.
- Keychain errors: ensure `gnome-keyring` packages are installed and the daemon is active in your session.
- Binary not found: confirm `~/.local/share/kdapps/kaspa-auth/kaspa-auth` exists and is executable.




