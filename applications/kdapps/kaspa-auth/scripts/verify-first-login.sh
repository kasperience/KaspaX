#!/usr/bin/env bash
set -euo pipefail

# Quick end-to-end checker for kaspa-auth first login setup.

CLI_BIN="${CLI_BIN:-$HOME/.cargo/bin/kaspa-auth}"
SOCKET_PATH="${XDG_RUNTIME_DIR:-/tmp}/kaspa-auth.sock"
DATA_DIR="$HOME/.local/share/kaspa-auth"
UNIT_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/kaspa-auth.service"

# Detect storage mode from installed unit
MODE="dev"
if [ -f "$UNIT_PATH" ] && grep -q -- "--keychain" "$UNIT_PATH"; then
  MODE="keychain"
fi

REPAIR=0
if [ "${1:-}" = "--repair" ]; then
  REPAIR=1
fi

log() { echo -e "[verify-first-login] $*"; }

repair() {
  log "Repair: reinstall unit and restart service"
  bash "$(cd "$(dirname "$0")" && pwd)/install-systemd-user.sh"
}

check_binary() {
  if [ -x "$CLI_BIN" ]; then
    log "✅ Binary present: $CLI_BIN"
  else
    log "❌ Binary missing at $CLI_BIN"
    log "   Build with: cargo install --path applications/kdapps/kaspa-auth --bin kaspa-auth"
    [ "$REPAIR" -eq 1 ] || return 1
  fi
}

check_unit() {
  if [ -f "$UNIT_PATH" ]; then
    log "✅ User unit installed: $UNIT_PATH"
  else
    log "❌ User unit not found at $UNIT_PATH"
    [ "$REPAIR" -eq 1 ] && repair || return 1
  fi
}

check_service_active() {
  if systemctl --user is-active --quiet kaspa-auth; then
    log "✅ Service active"
  else
    log "❌ Service not active"
    if [ "$REPAIR" -eq 1 ]; then
      systemctl --user enable --now kaspa-auth || true
      systemctl --user restart kaspa-auth || true
    else
      return 1
    fi
  fi
}

check_socket() {
  if [ -S "$SOCKET_PATH" ]; then
    log "✅ Socket present: $SOCKET_PATH"
  else
    log "❌ Socket missing: $SOCKET_PATH"
    [ "$REPAIR" -eq 1 ] || return 1
  fi
}

check_cli_status() {
  if "$CLI_BIN" daemon status --socket-path "$SOCKET_PATH" >/dev/null 2>&1; then
    log "✅ CLI can reach daemon"
  else
    log "❌ CLI cannot reach daemon via socket"
    return 1
  fi
}

check_wallet() {
  case "$MODE" in
    keychain)
      if "$CLI_BIN" --keychain wallet-status --username participant-peer --create >/dev/null 2>&1; then
        ADDR=$("$CLI_BIN" --keychain wallet-status --username participant-peer | awk -F": " '/Kaspa Address:/ {print $2; exit}')
        log "✅ Wallet OK (keychain, participant-peer). Address: ${ADDR:-unknown}"
      else
        log "❌ Wallet status failed (keychain)"
        return 1
      fi
      ;;
    *)
      if "$CLI_BIN" --dev-mode wallet-status --username participant-peer --create >/dev/null 2>&1; then
        ADDR=$("$CLI_BIN" --dev-mode wallet-status --username participant-peer | awk -F": " '/Kaspa Address:/ {print $2; exit}')
        log "✅ Wallet OK (dev, participant-peer). Address: ${ADDR:-unknown}"
      else
        log "❌ Wallet status failed (dev)"
        return 1
      fi
      ;;
  esac
}

main() {
  log "Mode detected from unit: $MODE"
  check_binary || true
  check_unit || true
  check_service_active || true
  check_socket || true
  check_cli_status || true
  check_wallet || true

  log "Done. Use --repair to attempt automated fixes."
}

main "$@"
