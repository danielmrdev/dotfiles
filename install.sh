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
#   2. personal apps — install required packages and Hache launcher
#   3. cleanup — remove unwanted Omarchy apps
#   4. git hooks — enable gitleaks pre-commit
#   5. Omarchy extras — custom themes and shell plugins
#   6. tooling — gitleaks itself
# Safe to re-run (idempotent).
set -eu

DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

echo "=== 1/6 Restoring config symlinks ==="
if [ -f "$DOTFILES/restore.sh" ]; then
  bash "$DOTFILES/restore.sh"
else
  echo "ERROR: $DOTFILES/restore.sh not found. Clone the dotfiles repo first." >&2
  exit 1
fi

echo ""
echo "=== 2/6 Installing personal apps ==="
# Official repository packages. Obsidian is included in Omarchy v4, but keep it
# explicit so setup remains correct if base package selection changes.
omarchy pkg add calibre nextcloud-client obsidian remmina spotify tailscale typora

# AUR packages.
omarchy pkg aur add bitwarden-bin espanso-wayland

# Hache is a custom web app; its launcher and icon were restored above.

echo ""
echo "=== 3/6 Removing unwanted Omarchy apps ==="
for app in \
  "Basecamp" \
  "Discord" \
  "Google Contacts" \
  "Google Maps" \
  "Google Messages" \
  "Google Photos" \
  "HEY" \
  "WhatsApp" \
  "X" \
  "YouTube"; do
  omarchy webapp remove "$app"
done

# Keep Calibre installed; hide only its E-book editor launcher.
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/calibre-ebook-edit.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=E-book editor
Hidden=true
EOF
update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true

# omarchy-nvim depends on neovim, so remove both packages together.
omarchy pkg drop aether cliamp foot kitty moonlight-qt omarchy-nvim neovim obs-studio zed

# Remove stale per-user launchers left behind after package removal.
rm -f "$HOME/.local/share/applications/foot.desktop" \
      "$HOME/.local/share/applications/footclient.desktop" \
      "$HOME/.local/share/applications/foot-server.desktop" \
      "$HOME/.local/share/applications/kitty.desktop" \
      "$HOME/.local/share/applications/kitty-open.desktop" \
      "$HOME/.local/share/applications/nvim.desktop"
update-desktop-database "$HOME/.local/share/applications" >/dev/null 2>&1 || true

echo ""
echo "=== 4/6 Enabling gitleaks pre-commit hook ==="
git -C "$DOTFILES" config core.hooksPath .githooks
echo "core.hooksPath = $(git -C "$DOTFILES" config core.hooksPath)"

echo ""
echo "=== 5/6 Installing Omarchy extras ==="
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
echo "=== 6/6 Tooling required by the dotfiles repo ==="
# Gitleaks — enforced by the repo's pre-commit hook (.githooks/pre-commit)
if ! command -v gitleaks >/dev/null 2>&1; then
  echo "Installing gitleaks..."
  omarchy pkg add gitleaks
fi

echo ""
echo "=== Done ==="
echo "Optional extras (manual):"
echo "  - teams-jiggler timer units need their helpers in ~/.local/bin (already restored)"
echo "  - verify after login: hyprctl reload && hyprctl configerrors"
