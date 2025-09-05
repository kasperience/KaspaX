# Kaspa Linux (kaspax) – First Login Setup

A simple, reliable “login and wallet first” flow for a Hyprland + SDDM Arch desktop. One system password unlocks the OS keyring; kaspa-auth runs as a user daemon and the First Login Wizard shows your wallet address and faucet link.

Note (current default): for setup convenience, the daemon is started in dev mode (file-backed wallet under `~/.local/share/kaspa-auth`). The keyring flow remains documented and is recommended for production.

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
From this repo’s root:

1) Build/install the binary
```
cargo install --path applications/kdapps/kaspa-auth --bin kaspa-auth
```

2) Install user systemd service
```
bash applications/kdapps/kaspa-auth/scripts/install-systemd-user.sh
# Logs: journalctl --user -u kaspa-auth -f
```

The service runs in your user session and places the socket at `$XDG_RUNTIME_DIR/kaspa-auth.sock`.

## Install First Login Wizard (Autostart)
Installs an autostart entry that runs once on first login to create/ensure the wallet and show the address.
```
bash applications/kdapps/kaspa-auth/scripts/install-first-login-autostart.sh
```
Manual one-time run (without relogin):
```
bash applications/kdapps/kaspa-auth/scripts/kaspa-first-login-wizard.sh
```

What the wizard does:
- Ensures daemon is running (starts it if needed)
- Ensures a `participant-peer` dev-mode wallet exists (file-backed)
- Displays the Kaspa address and a faucet link
- Writes `~/.local/share/kaspa-auth/.first_login_done` to avoid reruns

Disable/Reset:
- Remove autostart file: `~/.config/autostart/kaspa-first-login-wizard.desktop`
- Remove marker to run again: `rm ~/.local/share/kaspa-auth/.first_login_done`

## Verify
- Daemon status:
```
~/.cargo/bin/kaspa-auth daemon status --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock"
```
- Ping:
```
~/.cargo/bin/kaspa-auth daemon send --socket-path "$XDG_RUNTIME_DIR/kaspa-auth.sock" ping
```
- Wallet info (dev-mode, creates if missing):
```
~/.cargo/bin/kaspa-auth --dev-mode wallet-status --username participant-peer --create
```

## Operational Model
- Single system password unlocks your session and the Secret Service
- kaspa-auth loads keys from the keyring, no extra prompts
- Apps (kdapps) request signatures from the local daemon via `$XDG_RUNTIME_DIR/kaspa-auth.sock`

## Optional: USB / Local-File Wallet (Dev Mode)
A future optional feature for marketing/security demos: keep a dev-mode key on a removable USB. See:
- `applications/kdapps/kdapp-wallet/USB_SECURITY_IDEAS.md`

Recommended default remains OS keyring for zero-friction UX. Switch back by running the daemon without `--dev-mode` and using `--keychain` in CLI calls.

### Storage Mode Toggle
- Quick toggle scripts:
```
bash applications/kdapps/kaspa-auth/scripts/set-storage-mode.sh dev
bash applications/kdapps/kaspa-auth/scripts/set-storage-mode.sh keychain
```
- Scripts can honor keychain mode if you export:
```
export KASPAX_USE_KEYCHAIN=1
```

### Import Dev Key → Keychain
Keep your current dev-mode address by importing its private key into the keychain:
```
bash applications/kdapps/kaspa-auth/scripts/import-dev-key-to-keychain.sh --username participant-peer
```
Then switch the service to keychain mode and restart.

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
### Styling / Splash refresh
- The wizard splash page is generated on demand. To see style/template changes, re-run:
```
applications/kdapps/kaspa-auth/scripts/kaspa-first-login-wizard.sh --force
```
or open directly with your address:
```
ADDR=$(~/.cargo/bin/kaspa-auth --dev-mode wallet-status --username participant-peer --create | rg 'Kaspa Address:' | awk '{print $3}')
KASPA_NETWORK=testnet applications/kdapps/kaspa-auth/scripts/show-wizard-splash.sh "$ADDR"
```
## Troubleshooting

- No splash or wallet prompt after login:
  - The wizard runs once and then no-ops after writing `~/.local/share/kaspa-auth/.first_login_done`. Re-run explicitly:
    - `KASPAX_USE_KEYCHAIN=1 bash applications/kdapps/kaspa-auth/scripts/kaspa-first-login-wizard.sh --force`
- Daemon inactive or socket unreachable:
  - `bash applications/kdapps/kaspa-auth/scripts/verify-first-login.sh --repair`
  - If logs mention `--keychain` duplicated, normalize the unit and restart:
    - `bash applications/kdapps/kaspa-auth/scripts/repair-user-unit.sh`
    - `systemctl --user reset-failed kaspa-auth.service && systemctl --user restart kaspa-auth.service`
- Full reference: `applications/kdapps/kaspa-auth/UNIT_TROUBLESHOOTING.md`.
