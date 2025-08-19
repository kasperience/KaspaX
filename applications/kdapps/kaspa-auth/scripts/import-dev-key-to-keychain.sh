#!/usr/bin/env bash
set -euo pipefail

# Import a dev-mode private key (hex) into the OS keychain for kaspa-auth.
# - Reads ~/.local/share/kaspa-auth/.kaspa-auth/<username>.key by default
# - Stores secret via Secret Service using `secret-tool`
# - Verifies by querying `kaspa-auth --keychain wallet-status`

username="participant-peer"
data_dir="${KASPA_AUTH_DATA_DIR:-"$HOME/.local/share/kaspa-auth"}"
key_file=""
verify_only=false

usage() {
  cat >&2 <<EOF
Usage: $0 [--username NAME] [--data-dir PATH] [--key-file FILE] [--verify-only]

Defaults:
  --username    participant-peer
  --data-dir    \$KASPA_AUTH_DATA_DIR or ~/.local/share/kaspa-auth
  --key-file    <data-dir>/.kaspa-auth/<username>.key

Requires: secret-tool (libsecret), unlocked Secret Service (gnome-keyring)
EOF
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --username) username="${2:-}"; shift 2 ;;
    --data-dir) data_dir="${2:-}"; shift 2 ;;
    --key-file) key_file="${2:-}"; shift 2 ;;
    --verify-only) verify_only=true; shift ;;
    -h|--help) usage ;;
    *) echo "Unknown arg: $1" >&2; usage ;;
  esac
done

if ! command -v secret-tool >/dev/null 2>&1; then
  echo "Error: secret-tool not found. Install libsecret/gnome-keyring." >&2
  exit 1
fi

BIN="$HOME/.cargo/bin/kaspa-auth"
if [ ! -x "$BIN" ]; then
  echo "Error: kaspa-auth CLI not found at $BIN" >&2
  exit 1
fi

if [ -z "$key_file" ]; then
  key_file="$data_dir/.kaspa-auth/${username}.key"
fi

if [ "$verify_only" = false ]; then
  if [ ! -f "$key_file" ]; then
    echo "Error: dev key file not found: $key_file" >&2
    exit 1
  fi
  key_hex="$(tr -d '\n\r ' < "$key_file")"
  if [[ ! "$key_hex" =~ ^[0-9a-fA-F]+$ ]]; then
    echo "Error: key file does not look like hex: $key_file" >&2
    exit 1
  fi

  echo "[import] Storing key in Secret Service: service=kaspa-auth username=$username" >&2
  printf "%s" "$key_hex" | secret-tool store --label="kaspa-auth:$username" service kaspa-auth username "$username"
  echo "[import] Stored. Verifying…" >&2
fi

# Verify retrieval via CLI (keychain)
if "$BIN" --keychain wallet-status --username "$username" >/dev/null 2>&1; then
  "$BIN" --keychain wallet-status --username "$username" | sed -n '1,5p'
  echo "[import] Success: key accessible via keychain for '$username'" >&2
  exit 0
else
  echo "[import] Verification failed. Ensure keyring is unlocked and try again." >&2
  exit 1
fi

