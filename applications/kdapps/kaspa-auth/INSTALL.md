# Kaspa Auth – Install & First Login (Arch + Hyprland)

This guide installs the `kaspa-auth` daemon (user service), sets up the first-login wizard, and verifies everything.

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
From the kdapp workspace root:

```
cargo install --path examples/kaspa-auth --bin kaspa-auth
~/.cargo/bin/kaspa-auth --help
```

## Enable Daemon (systemd user)
From this app folder:

```
cd examples/kaspa-linux/kaspax/applications/kdapps/kaspa-auth
scripts/install-systemd-user.sh
systemctl --user status kaspa-auth
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
```
# Socket present
ss -lpn | rg kaspa-auth.sock || ls "$XDG_RUNTIME_DIR"/kaspa-auth.sock

# Daemon responds
~/.cargo/bin/kaspa-auth -- daemon status --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock"
~/.cargo/bin/kaspa-auth -- daemon send ping --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock"

# Keychain-backed wallet
~/.cargo/bin/kaspa-auth --keychain wallet-status --username participant-peer --create
```

You should see the address printed in the terminal. If `qrencode` is installed, the splash shows a QR.

## Troubleshooting
- Keyring locked at login: ensure PAM lines were added to `/etc/pam.d/sddm` and `/etc/pam.d/sddm-autologin` and perform a full logout/login.
- `xdg-open` not found / splash not opening: install `xdg-utils` and a browser.
- Systemd user not running: run inside the GUI session; for lingering services: `loginctl enable-linger $USER`.
- QR missing: install `qrencode`.

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

