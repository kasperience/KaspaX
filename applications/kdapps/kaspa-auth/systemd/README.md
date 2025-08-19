This directory contains the systemd user unit for running the `kaspa-auth` daemon.

Install and enable for the current user:

1. Copy to `~/.config/systemd/user/`:
   - `cp -f kaspa-auth.service ~/.config/systemd/user/kaspa-auth.service`
2. Reload and enable:
   - `systemctl --user daemon-reload`
   - `systemctl --user enable --now kaspa-auth.service`
3. Tail logs:
   - `journalctl --user -u kaspa-auth -f`

You can also use the helper script in `scripts/install-systemd-user.sh`.

