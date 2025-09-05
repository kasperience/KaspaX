#!/usr/bin/env bash
set -euo pipefail

# Kaspa Auth – First Login Wizard
# Goal: on first login, ensure daemon is running, ensure a keychain wallet exists,
# show the wallet address with a faucet hint, and mark completion to avoid repeats.

WIZARD_MARKER="$HOME/.local/share/kaspa-auth/.first_login_done"
SOCKET_PATH="${XDG_RUNTIME_DIR:-/tmp}/kaspa-auth.sock"
CLI_BIN="${CLI_BIN:-$HOME/.cargo/bin/kaspa-auth}"

# Storage mode: default to dev mode (file-backed). Set KASPAX_USE_KEYCHAIN=1 to use keychain.
USE_KEYCHAIN="${KASPAX_USE_KEYCHAIN:-0}"

log() { echo -e "[kaspa-first-login] $*"; }

ensure_dirs() {
  mkdir -p "$HOME/.local/share/kaspa-auth"
}

start_daemon() {
  if command -v systemctl >/dev/null 2>&1; then
    if ! systemctl --user is-active --quiet kaspa-auth; then
      log "Starting kaspa-auth user service..."
      systemctl --user start kaspa-auth || true
    fi
  fi

  # Fallback: try foreground daemon if service isn't running and binary is present
  # Use a direct Unix socket check to avoid RTNETLINK noise from ss
  if [ ! -S "$SOCKET_PATH" ]; then
    if ! systemctl --user is-active --quiet kaspa-auth; then
      if [ -x "$CLI_BIN" ]; then
        log "Launching kaspa-auth daemon in background (fallback)..."
        if [ "$USE_KEYCHAIN" = "1" ]; then
          ("$CLI_BIN" --keychain daemon start --foreground \
            --socket-path "$SOCKET_PATH" \
            --data-dir "$HOME/.local/share/kaspa-auth" \
            >/dev/null 2>&1 & disown) || true
        else
          ("$CLI_BIN" --dev-mode daemon start --foreground \
          --socket-path "$SOCKET_PATH" \
          --data-dir "$HOME/.local/share/kaspa-auth" \
          >/dev/null 2>&1 & disown) || true
        fi
      fi
    fi
  fi
}

wait_for_socket() {
  log "Waiting for daemon socket at $SOCKET_PATH ..."
  for i in {1..30}; do
    if [ -S "$SOCKET_PATH" ]; then
      return 0
    fi
    sleep 0.3
  done
  log "Warning: daemon socket not detected; continuing anyway."
}

ensure_wallet() {
  # Ensure wallet exists; default dev mode unless keychain explicitly requested
  if [ "$USE_KEYCHAIN" = "1" ]; then
    log "Ensuring keychain wallet exists (participant-peer)..."
    "$CLI_BIN" --keychain wallet-status --username participant-peer --create || true
  else
    log "Ensuring dev-mode wallet exists (participant-peer)..."
    "$CLI_BIN" --dev-mode wallet-status --username participant-peer --create || true
  fi
}

extract_address() {
  # Parse address from wallet-status output
  local out
  if [ "$USE_KEYCHAIN" = "1" ]; then
    out=$("$CLI_BIN" --keychain wallet-status --username participant-peer 2>/dev/null || true)
  else
    out=$("$CLI_BIN" --dev-mode wallet-status --username participant-peer 2>/dev/null || true)
  fi
  echo "$out" | awk -F": " '/Kaspa Address:/ {print $2; exit}'
}

show_summary() {
  local addr="$1"
  echo
  echo "========================================"
  echo " Kaspa Auth – First Login Setup"
  echo "========================================"
  if [ "$USE_KEYCHAIN" = "1" ]; then
    echo "🔑 Identity: participant-peer (OS keychain)"
  else
    echo "🔑 Identity: participant-peer (dev mode)"
  fi
  if [ -n "$addr" ]; then
    echo "💰 Address: $addr"
    echo "💡 Fund (testnet): https://faucet.kaspanet.io/"
  else
    echo "⚠️  Could not detect address automatically."
    echo "   Run: $CLI_BIN --keychain wallet-status --username participant-peer"
  fi
  echo
  echo "Next: Start an organizer peer and authenticate via daemon when needed."
  echo "CLI tips:"
  echo "  $CLI_BIN daemon status --socket-path \"$SOCKET_PATH\""
  echo "  $CLI_BIN daemon send --socket-path \"$SOCKET_PATH\" ping"
  echo
}

main() {
  ensure_dirs

  if [ -f "$WIZARD_MARKER" ]; then
    log "First login already completed. Exiting."
    exit 0
  fi

  if ! command -v "$CLI_BIN" >/dev/null 2>&1; then
    echo "kaspa-auth binary not found at $CLI_BIN"
    echo "Install with: cargo install --path applications/kdapps/kaspa-auth --bin kaspa-auth"
    exit 0
  fi

  start_daemon
  wait_for_socket
  ensure_wallet
  local addr
  addr=$(extract_address || true)
  show_summary "$addr"

  # Mark as done to avoid rerun
  touch "$WIZARD_MARKER"
}

main "$@"
