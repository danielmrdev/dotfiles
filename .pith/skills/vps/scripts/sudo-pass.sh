#!/usr/bin/env bash
# Retrieve sudo password for a VPS host from macOS Keychain.
# Usage: sudo-pass.sh <hostname>
# Keychain convention: service = "vps-sudo-<hostname>", account = user (e.g. "daniel").
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: $0 <hostname>" >&2
  exit 2
fi

HOST="$1"
ACCOUNT="${2:-daniel}"
security find-generic-password -a "$ACCOUNT" -s "vps-sudo-${HOST}" -w
