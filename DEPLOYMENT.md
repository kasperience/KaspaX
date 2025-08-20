### Deploying and Testing kaspa-auth on Kaspa Linux

This guide explains how to pull your fork on an already installed Kaspa Linux system, deploy the `kaspa-auth` daemon, enable it as a user service, and test end-to-end. It also covers applying the Kaspa theme.

#### Prerequisites
- An installed Kaspa Linux system (user session)
- Network access and `yay`
- Rust toolchain if building locally: `rustup` (optional if you ship binaries)
- Keychain services for secrets: `gnome-keyring libsecret seahorse`

```bash
yay -S --needed gnome-keyring libsecret seahorse
```

### 1) Point the installed Kaspa Linux to your fork and update
By default, Kaspa Linux lives at `~/.local/share/kaspa-linux` on the installed system.

```bash
# Replace with your fork URL (SSH or HTTPS)
git -C ~/.local/share/kaspa-linux remote set-url origin <your-fork-url>

# Pull latest changes
~/.local/share/kaspa-linux/bin/kaspa-linux-update
```

If you have local changes in that tree, commit or discard them before pulling.

### 2) Build and install the kaspa-auth binary (manual deployment)
If you have not added a migration that installs the binary automatically, build and place it under `~/.local/share/kdapps/kaspa-auth/`:

```bash
mkdir -p ~/.local/share/kdapps/kaspa-auth
cd ~/KaspaX/applications/kdapps/kaspa-auth
cargo build --release
install -Dm755 target/release/kaspa-auth ~/.local/share/kdapps/kaspa-auth/kaspa-auth
```

Tip: You can automate these steps later via a migration script in `migrations/`.

### 3) Enable the kaspa-auth systemd user service
The service unit is provided by the repo: `config/systemd/user/kaspa-auth.service`.

```bash
mkdir -p ~/.config/systemd/user
cp ~/.local/share/kaspa-linux/config/systemd/user/kaspa-auth.service ~/.config/systemd/user/
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
# Install a theme repo; the tool places it under ~/.config/kaspa-linux/themes/
~/.local/share/kaspa-linux/bin/kaspa-linux-theme-install <theme-git-url>

# Set theme by name (case/space-insensitive)
~/.local/share/kaspa-linux/bin/kaspa-linux-theme-set kaspa

# List available themes
~/.local/share/kaspa-linux/bin/kaspa-linux-theme-list
```

If your theme already exists under `~/.config/kaspa-linux/themes/`, just run `kaspa-linux-theme-set`.

### 6) Updating later

```bash
~/.local/share/kaspa-linux/bin/kaspa-linux-update
```

This pulls from your fork, refreshes configs, and offers to update system packages.

### Troubleshooting
- Service not found: re-copy the unit to `~/.config/systemd/user/` and `daemon-reload`.
- Keychain errors: ensure `gnome-keyring` packages are installed and the daemon is active in your session.
- Binary not found: confirm `~/.local/share/kdapps/kaspa-auth/kaspa-auth` exists and is executable.


