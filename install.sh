#!/bin/bash
# install.sh — Post-clean-install setup for Omarchy
#
# Run AFTER a fresh Omarchy install has cloned this repo:
#   git clone git@github.com:danielmrdev/dotfiles.git ~/.dotfiles
#   bash ~/.dotfiles/install.sh
#
# Does everything needed to go from a clean Omarchy install to the full
# personal setup:
#   1. restore.sh — symlink config into place
#   2. git hooks — enable gitleaks pre-commit
#   3. Omarchy extras — custom themes and shell plugins
#   4. tooling — gitleaks itself
# Safe to re-run (idempotent).
set -eu

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

echo "=== 1/4 Restoring config symlinks ==="
if [ -f "$DOTFILES/restore.sh" ]; then
  bash "$DOTFILES/restore.sh"
else
  echo "ERROR: $DOTFILES/restore.sh not found. Clone the dotfiles repo first." >&2
  exit 1
fi

echo ""
echo "=== 2/4 Enabling gitleaks pre-commit hook ==="
git -C "$DOTFILES" config core.hooksPath .githooks
echo "core.hooksPath = $(git -C "$DOTFILES" config core.hooksPath)"

echo ""
echo "=== 3/4 Installing Omarchy extras ==="
# Harbor — custom third-party theme (not part of stock Omarchy themes)
omarchy theme install https://github.com/HANCORE-linux/omarchy-harbor-theme

# Apply the active theme (matches current setup; change with: omarchy theme set <name>)
omarchy theme set "Retro 82"

# Omadoro — pomodoro timer bar widget (third-party git plugin)
omarchy plugin add https://github.com/brianblakely/omadoro.git --enable

# Omarchy Calendar — replaces the built-in clock (tmn73.calendar)
omarchy plugin add https://github.com/tmn73/omarchy-calendar.git --enable

# Nightman — night/day theme switching (codefriendly.nightman)
omarchy plugin add https://github.com/codefriendly/omarchy-nightman.git --enable

echo ""
echo "=== 4/4 Tooling required by the dotfiles repo ==="
# Gitleaks — enforced by the repo's pre-commit hook (.githooks/pre-commit)
if ! command -v gitleaks >/dev/null 2>&1; then
  echo "Installing gitleaks..."
  omarchy pkg add gitleaks
fi

echo ""
echo "=== Done ==="
echo "Optional extras (manual):"
echo "  - espanso (user unit espanso.service linked by restore.sh): omarchy pkg add espanso"
echo "  - teams-jiggler timer units need their helpers in ~/.local/bin (already restored)"
echo "  - verify after login: hyprctl reload && hyprctl configerrors"
