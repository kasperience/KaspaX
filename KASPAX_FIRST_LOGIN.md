# Kaspa Linux (kaspax) – First Login Setup

A simple, reliable “login and wallet first” flow for a Hyprland + SDDM Arch desktop. One system password unlocks the OS keyring; kaspa-auth runs as a user daemon and the First Login Wizard shows your wallet address and faucet link.

## What You Get
- Kaspa-auth daemon autostarted as a user service (no root)
- Key stored in the OS keyring (Secret Service)
- First Login Wizard runs once, ensures identity, shows funding address
- Clean Hyprland session (no extra prompts)

## Prerequisites
- Arch Linux with SDDM + Hyprland session
- Packages: `gnome-keyring`, `libsecret`, `systemd` (user session)
- Rust toolchain (for building binaries)

## Configure Keyring Unlock (SDDM PAM)
Make SDDM unlock the Secret Service at login so no extra prompts are needed.

Edit both files and add the lines below if missing:
- `/etc/pam.d/sddm`
- `/etc/pam.d/sddm-autologin`

Add:
```
# Unlock Secret Service (GNOME Keyring)
auth     optional    pam_gnome_keyring.so
session  optional    pam_gnome_keyring.so auto_start
```

Optional Hyprland fallback (if PAM doesn’t unlock): add to `~/.config/hypr/hyprland.conf`:
```
exec-once = gnome-keyring-daemon --start --components=secrets,ssh
```

## Install kaspa-auth + Daemon Service
From this repo’s root (kdapp):

1) Build/install the binary
```
cargo install --path examples/kaspa-auth --bin kaspa-auth
```

2) Install user systemd service
```
bash examples/kaspa-auth/scripts/install-systemd-user.sh
# Logs: journalctl --user -u kaspa-auth -f
```

The service runs in your user session and places the socket at `$XDG_RUNTIME_DIR/kaspa-auth.sock`.

## Install First Login Wizard (Autostart)
Installs an autostart entry that runs once on first login to create/ensure the wallet and show the address.
```
bash examples/kaspa-auth/scripts/install-first-login-autostart.sh
```
Manual one-time run (without relogin):
```
bash examples/kaspa-auth/scripts/kaspa-first-login-wizard.sh
```

What the wizard does:
- Ensures daemon is running (starts it if needed)
- Ensures a `participant-peer` keychain wallet exists
- Displays the Kaspa address and a faucet link
- Writes `~/.local/share/kaspa-auth/.first_login_done` to avoid reruns

Disable/Reset:
- Remove autostart file: `~/.config/autostart/kaspa-first-login-wizard.desktop`
- Remove marker to run again: `rm ~/.local/share/kaspa-auth/.first_login_done`

## Verify
- Daemon status:
```
kaspa-auth -- daemon status --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock"
```
- Ping:
```
kaspa-auth -- daemon send ping --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock"
```
- Wallet info (OS keyring):
```
kaspa-auth --keychain wallet-status --username participant-peer
```

## Operational Model
- Single system password unlocks your session and the Secret Service
- kaspa-auth loads keys from the keyring, no extra prompts
- Apps (kdapps) request signatures from the local daemon via `$XDG_RUNTIME_DIR/kaspa-auth.sock`

## Optional: USB / Local-File Wallet (Dev Mode)
A future optional feature for marketing/security demos: keep a dev-mode key on a removable USB. See:
- `applications/kdapps/kdapp-wallet/USB_SECURITY_IDEAS.md`

Recommended default remains OS keyring for zero-friction UX.

## Troubleshooting
- Keyring not unlocked:
  - Re-check PAM lines in `/etc/pam.d/sddm` and `/etc/pam.d/sddm-autologin`
  - Try Hyprland fallback: `gnome-keyring-daemon --start --components=secrets,ssh`
- Daemon socket missing:
  - `journalctl --user -u kaspa-auth -f`
  - Ensure `$XDG_RUNTIME_DIR` exists and is user-writable
- Wizard didn’t run:
  - Confirm autostart: `~/.config/autostart/kaspa-first-login-wizard.desktop`
  - Remove marker file to re-run

## Next Steps
- Add a minimal organizer peer desktop entry or script for a full local demo
- Optionally add a small GUI splash (QR code for the address) to the wizard

---
This guide tracks the kaspa-auth integration steps to avoid missing pieces during install.
