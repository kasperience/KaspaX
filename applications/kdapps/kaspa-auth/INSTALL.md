# Kaspa Auth – Install & First Login (Arch + Hyprland)

This guide installs the `kaspa-auth` daemon (user service), sets up the first-login wizard, and verifies everything.

Note: current default runs in dev-mode (file-backed wallet under `~/.local/share/kaspa-auth`) to simplify first-run. Production can switch to keyring mode later.

## Prerequisites
- Arch Linux VM or machine
- Hyprland + SDDM (or other desktop; examples assume SDDM)
- Rust toolchain, Git
- Keyring & portals: gnome-keyring, libsecret, xdg-utils
- Optional: `qrencode` to render local QR in the splash

## System Setup (copy/paste)

```
sudo pacman -Syu --noconfirm
sudo pacman -S --needed base-devel git rustup pkgconf openssl \
  gnome-keyring libsecret xdg-desktop-portal xdg-utils \
  hyprland xdg-desktop-portal-hyprland xorg-xwayland waybar kitty wl-clipboard wlogout sddm \
  qrencode firefox

rustup default stable
rustup component add clippy rustfmt

# Enable SDDM
sudo systemctl enable --now sddm

# (Optional) Autologin into Hyprland
sudo install -d /etc/sddm.conf.d
cat | sudo tee /etc/sddm.conf.d/autologin.conf >/dev/null <<EOF
[Autologin]
User=$USER
Session=hyprland
EOF

# Unlock GNOME Keyring at login (SDDM)
for f in /etc/pam.d/sddm /etc/pam.d/sddm-autologin; do
  if ! grep -q 'pam_gnome_keyring.so' "$f"; then
    echo "Configuring PAM: $f"
    echo 'auth     optional  pam_gnome_keyring.so' | sudo tee -a "$f" >/dev/null
    echo 'session  optional  pam_gnome_keyring.so auto_start' | sudo tee -a "$f" >/dev/null
  fi
done
```

Log out and log in to your desktop session after PAM changes.

## Build & Install `kaspa-auth`
From the KaspaX repo root (`/home/<you>/KaspaX`):

```
cargo install --path applications/kdapps/kaspa-auth --bin kaspa-auth
~/.cargo/bin/kaspa-auth --help
systemctl --user restart kaspa-auth.service  # restart to pick up new binary
```

## Enable Daemon (systemd user)
From this app folder:

```
cd applications/kdapps/kaspa-auth
scripts/install-systemd-user.sh
systemctl --user status kaspa-auth --no-pager -l
journalctl --user -u kaspa-auth -f
```

## First-Login Wizard
- Autostart on GUI login (runs once):

```
scripts/install-first-login-autostart.sh
```

- Manual run anytime:

```
scripts/kaspa-first-login-wizard.sh
```

- Directly open the splash (HTML in browser):

```
scripts/show-wizard-splash.sh <kaspa_address>
```

Marker file to prevent reruns: `~/.local/share/kaspa-auth/.first_login_done`.

## Verify
Fast path (repairs unit, ensures dirs, starts service, then checks):
```
bash applications/kdapps/kaspa-auth/scripts/verify-first-login.sh --repair
bash applications/kdapps/kaspa-auth/scripts/verify-first-login.sh
```

Manual checks:
```
# Socket present
ss -lpn | rg kaspa-auth.sock || ls "$XDG_RUNTIME_DIR"/kaspa-auth.sock

# Daemon responds
~/.cargo/bin/kaspa-auth daemon status --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock"
~/.cargo/bin/kaspa-auth daemon send --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock" ping

# Dev-mode wallet (creates if missing and prints address)
~/.cargo/bin/kaspa-auth --dev-mode wallet-status --username participant-peer --create
```

### Unlock identity for daemon signing (dev mode)
In dev mode, unlock caches the identity in the daemon for signing:
```
~/.cargo/bin/kaspa-auth daemon send --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock" unlock \
  --username participant-peer --password devpass
```

### Switch storage mode later
- Toggle to dev (file):
```
bash applications/kdapps/kaspa-auth/scripts/set-storage-mode.sh dev
```
- Toggle to keychain:
```
bash applications/kdapps/kaspa-auth/scripts/set-storage-mode.sh keychain
```
- Scripts can also be forced to keychain by exporting:
```
export KASPAX_USE_KEYCHAIN=1
```

### Migrate dev key to keychain
Import your existing dev-mode private key into the OS keychain (keeps the same address):
```
bash applications/kdapps/kaspa-auth/scripts/import-dev-key-to-keychain.sh --username participant-peer
# Verify
~/.cargo/bin/kaspa-auth --keychain wallet-status --username participant-peer
```
Notes:
- Requires `secret-tool` (libsecret) and an unlocked keyring (PAM/gnome-keyring).
- Default dev key path: `~/.local/share/kaspa-auth/.kaspa-auth/<username>.key`.

You should see the address printed in the terminal. If `qrencode` is installed, the splash shows a QR.

## Troubleshooting
- Keyring locked at login: ensure PAM lines were added to `/etc/pam.d/sddm` and `/etc/pam.d/sddm-autologin` and perform a full logout/login.
- `xdg-open` not found / splash not opening: install `xdg-utils` and a browser.
- Systemd user not running: run inside the GUI session; for lingering services: `loginctl enable-linger $USER`.
- QR missing: install `qrencode`.

If the service doesn’t start:
```
systemctl --user status kaspa-auth.service --no-pager -l
journalctl --user -xeu kaspa-auth.service --no-pager -l
```

```
Paths used by scripts:
  Binary:           ~/.cargo/bin/kaspa-auth
  Socket:           $XDG_RUNTIME_DIR/kaspa-auth.sock
  Data dir:         ~/.local/share/kaspa-auth
  First-run marker: ~/.local/share/kaspa-auth/.first_login_done
```

## Notes
- The GUI splash uses `public/assets/kdapp_framework.jpg` for branding and a neutral dark palette with green accents.
- The first-login wizard opens the splash automatically after printing the address.
- All scripts are in `scripts/` and can be inspected or modified as needed.
