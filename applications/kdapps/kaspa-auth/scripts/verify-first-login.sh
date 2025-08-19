#!/usr/bin/env bash
set -euo pipefail

# Quick end-to-end verifier for kaspa-auth first login setup.
# Optionally self-repairs the user unit and base directories when run with --repair.

PASS=0; FAIL=0
ok() { printf "[ OK ] %s\n" "$*"; PASS=$((PASS+1)); }
ko() { printf "[FAIL] %s\n" "$*"; FAIL=$((FAIL+1)); }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
UNIT_SRC="$APP_ROOT/systemd/kaspa-auth.service"
UNIT_DST="$HOME/.config/systemd/user/kaspa-auth.service"
export KASPA_AUTH_DATA_DIR="$HOME/.local/share/kaspa-auth"

BIN="$HOME/.cargo/bin/kaspa-auth"
SOCK="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/kaspa-auth.sock"
USERNAME="participant-peer"

# Storage mode toggle: set KASPAX_USE_KEYCHAIN=1 for keyring
MODE_FLAGS="--dev-mode"
if [ "${KASPAX_USE_KEYCHAIN:-0}" = "1" ]; then
  MODE_FLAGS="--keychain"
fi

REPAIR=false
for arg in "$@"; do
  case "$arg" in
    --repair|--fix)
      REPAIR=true
      ;;
  esac
done

if [ "$REPAIR" = true ]; then
  echo "[verify] Repair mode: updating unit and preparing directories" >&2
  mkdir -p "$HOME/.local/share/kaspa-auth" || true
  if [ -f "$UNIT_SRC" ]; then
    mkdir -p "$(dirname "$UNIT_DST")"
    install -m 0644 "$UNIT_SRC" "$UNIT_DST"
    systemctl --user daemon-reload || true
    systemctl --user enable --now kaspa-auth.service || true
    # Give systemd a brief moment to start the service
    sleep 0.3 || true
  else
    echo "[verify] Warning: unit source not found at $UNIT_SRC" >&2
  fi
fi

# 1) Binary present
if [ -x "$BIN" ]; then ok "Binary present: $BIN"; else ko "Missing binary: $BIN"; fi

# 2) Systemd user service
if systemctl --user is-enabled kaspa-auth.service >/dev/null 2>&1; then
  ok "Service enabled (user)"
else
  ko "Service not enabled (user)"
fi

if systemctl --user is-active kaspa-auth.service >/dev/null 2>&1; then
  ok "Service active (user)"
else
  ko "Service not active (user)"
fi

# 3) Socket exists
if [ -S "$SOCK" ]; then ok "Socket present: $SOCK"; else ko "Socket missing: $SOCK"; fi

# 4) Daemon responds
if "$BIN" daemon status --socket-path "$SOCK" >/dev/null 2>&1; then
  ok "Daemon status responded"
else
  ko "Daemon status failed"
fi

if "$BIN" daemon send ping --socket-path "$SOCK" >/dev/null 2>&1; then
  ok "Daemon ping responded"
else
  ko "Daemon ping failed"
fi

# 5) Wallet exists. Create if missing.
if "$BIN" $MODE_FLAGS wallet-status --username "$USERNAME" --create >/dev/null 2>&1; then
  if [ "$MODE_FLAGS" = "--keychain" ]; then
    ok "Wallet available (keychain) for $USERNAME"
  else
    ok "Wallet available (dev-mode file) for $USERNAME"
  fi
else
  ko "Wallet check failed for $USERNAME"
fi

printf "\nSummary: %d OK, %d FAIL\n" "$PASS" "$FAIL"
exit $(( FAIL == 0 ? 0 : 1 ))
