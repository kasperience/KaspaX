#!/usr/bin/env bash
set -euo pipefail

# set-storage-mode.sh dev|keychain
# Regenerates the user systemd unit for kaspa-auth with the chosen storage mode
# and restarts the service. Idempotent; ensures no duplicate mode flags.

mode=${1:-}
if [[ -z "${mode}" || ("${mode}" != "dev" && "${mode}" != "keychain") ]]; then
  echo "Usage: $0 <dev|keychain>" >&2
  exit 1
fi

UNIT_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
UNIT_PATH="$UNIT_DIR/kaspa-auth.service"
mkdir -p "$UNIT_DIR"

BIN="$HOME/.cargo/bin/kaspa-auth"
SOCKET_PATH="%t/kaspa-auth.sock"
DATA_DIR="%h/.local/share/kaspa-auth"

case "$mode" in
  dev)
    MODE_FLAG="--dev-mode"
    ;;
  keychain)
    MODE_FLAG="--keychain"
    ;;
esac

# Best-effort: clear any stale runtime socket before we restart the unit
if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
  rm -f "${XDG_RUNTIME_DIR}/kaspa-auth.sock" || true
fi

cat >"$UNIT_PATH" <<UNIT
[Unit]
Description=Kaspa Auth Daemon (user)
After=default.target graphical-session.target
Wants=graphical-session.target

[Service]
Type=simple
ExecStart=${BIN} ${MODE_FLAG} daemon start --foreground --socket-path ${SOCKET_PATH} --data-dir ${DATA_DIR} --session-timeout 3600
Environment=KASPA_AUTH_DATA_DIR=%h/.local/share/kaspa-auth
Restart=always
RestartSec=2s

# Hardening
ProtectSystem=full
ProtectHome=read-only
ReadWritePaths=%h/.local/share %t
NoNewPrivileges=yes
PrivateTmp=yes
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectControlGroups=yes
MemoryDenyWriteExecute=yes
LockPersonality=yes

[Install]
WantedBy=default.target
UNIT

# Normalize any accidental duplicates and mixed modes (belt-and-suspenders)
sed -E -i 's/--keychain[[:space:]]+--keychain/--keychain/g' "$UNIT_PATH" || true
sed -E -i 's/--dev-mode[[:space:]]+--dev-mode/--dev-mode/g' "$UNIT_PATH" || true
if grep -qE 'ExecStart=.*--dev-mode.*--keychain|ExecStart=.*--keychain.*--dev-mode' "$UNIT_PATH"; then
  # Prefer the explicitly selected MODE_FLAG
  case "$mode" in
    dev)
      sed -E -i 's/--keychain[[:space:]]+//g' "$UNIT_PATH"
      ;;
    keychain)
      sed -E -i 's/--dev-mode[[:space:]]+//g' "$UNIT_PATH"
      ;;
  esac
fi

count=$(grep -c -- "$MODE_FLAG" "$UNIT_PATH")
if [[ "$count" -ne 1 ]]; then
  echo "[set-storage-mode] Expected exactly one $MODE_FLAG flag in $UNIT_PATH, found $count" >&2
  exit 1
fi

echo "[set-storage-mode] Wrote ${UNIT_PATH} (mode=${mode})"
systemctl --user daemon-reload
systemctl --user reset-failed kaspa-auth.service || true
systemctl --user enable --now kaspa-auth.service >/dev/null 2>&1 || true
systemctl --user restart kaspa-auth.service || true
echo "[set-storage-mode] Reloaded and restarted user service"
echo "[set-storage-mode] Done. Verify: applications/kdapps/kaspa-auth/scripts/verify-first-login.sh"

