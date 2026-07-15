#!/bin/bash
# save.sh — Copy current configs into ~/.dotfiles/ and commit+push
set -e

DOTFILES="$HOME/.dotfiles"

echo "=== Copying configs to $DOTFILES ==="

# Hyprland
echo "[hypr]"
cp -a "$HOME/.config/hypr/"*.conf "$DOTFILES/.config/hypr/"
cp -a "$HOME/.config/hypr/hy3.conf" "$DOTFILES/.config/hypr/" 2>/dev/null || true
cp -a "$HOME/.config/hypr/hy3-layout-watch.sh" "$DOTFILES/.config/hypr/" 2>/dev/null || true

# Waybar (exclude .bak files)
echo "[waybar]"
for f in "$HOME/.config/waybar/"*; do
  b="$(basename "$f")"
  [[ "$b" == *.bak.* ]] || [[ "$b" == *.bak[0-9]* ]] || [[ "$b" == *.bak_* ]] || cp -a "$f" "$DOTFILES/.config/waybar/"
done

# Walker
echo "[walker]"
cp -a "$HOME/.config/walker/config.toml" "$DOTFILES/.config/walker/"

# SwayOSD
echo "[swayosd]"
cp -a "$HOME/.config/swayosd/"* "$DOTFILES/.config/swayosd/"

# Btop
echo "[btop]"
cp -a "$HOME/.config/btop/btop.conf" "$DOTFILES/.config/btop/"

# Fastfetch
echo "[fastfetch]"
cp -a "$HOME/.config/fastfetch/"* "$DOTFILES/.config/fastfetch/"

# Terminals
echo "[terminals]"
cp -a "$HOME/.config/alacritty/alacritty.toml" "$DOTFILES/.config/alacritty/" 2>/dev/null || true
cp -a "$HOME/.config/ghostty/config" "$DOTFILES/.config/ghostty/" 2>/dev/null || true
cp -a "$HOME/.config/foot/foot.ini" "$DOTFILES/.config/foot/" 2>/dev/null || true

# Systemd user services (custom only, exclude symlink targets/wants dirs)
echo "[systemd]"
for f in "$HOME/.config/systemd/user/"*.service "$HOME/.config/systemd/user/"*.timer; do
  [ -f "$f" ] || continue
  # Skip symlinks to /dev/null (Nextcloud noise)
  [ -L "$f" ] && [ "$(readlink "$f")" = "/dev/null" ] && continue
  cp -a "$f" "$DOTFILES/.config/systemd/user/"
done
# Service drop-in overrides
for d in "$HOME/.config/systemd/user/"*.service.d; do
  [ -d "$d" ] && cp -a "$d" "$DOTFILES/.config/systemd/user/" || true
done

# Autostart
echo "[autostart]"
cp -a "$HOME/.config/autostart/"*.desktop "$DOTFILES/.config/autostart/"

# Environment
echo "[environment]"
cp -a "$HOME/.config/environment.d/"* "$DOTFILES/.config/environment.d/"

# Chromium flags
echo "[chromium-flags]"
cp -a "$HOME/.config/chromium-flags.conf" "$DOTFILES/.config/" 2>/dev/null || true

# Omarchy hooks
echo "[omarchy hooks]"
cp -a "$HOME/.config/omarchy/hooks/"* "$DOTFILES/.config/omarchy/hooks/" 2>/dev/null || true

# Omarchy custom theme
echo "[omarchy theme harbor]"
cp -a "$HOME/.config/omarchy/themes/harbor/"* "$DOTFILES/.config/omarchy/themes/harbor/" 2>/dev/null || true

# Omarchy extensions
echo "[omarchy extensions]"
cp -a "$HOME/.config/omarchy/extensions/"* "$DOTFILES/.config/omarchy/extensions/" 2>/dev/null || true

# Omarchy branding
echo "[omarchy branding]"
cp -a "$HOME/.config/omarchy/branding/"* "$DOTFILES/.config/omarchy/branding/" 2>/dev/null || true

# Custom scripts
echo "[scripts]"
for f in "$HOME/.local/bin/teams-jiggler" "$HOME/.local/bin/teams-jiggler-status" \
         "$HOME/.local/bin/teams-jiggler-toggle" "$HOME/.local/bin/teams-jiggler-off" \
         "$HOME/.local/bin/nextcloud-external-guard" "$HOME/.local/bin/neon-pilot-app" \
         "$HOME/.local/bin/omniroute"; do
  [ -f "$f" ] && cp -a "$f" "$DOTFILES/.local/bin/" || true
done

echo ""
echo "=== Git add + commit ==="
cd "$DOTFILES"

# Update .gitignore to exclude macOS artifacts and backups
cat > .gitignore << 'GITIGNORE'
Brewfile.lock.json
themes/
.zshrc_old
.zshenv.local
*.bak.*
.bak/
GITIGNORE

git add -A

if git diff --cached --quiet; then
  echo "Nothing changed — skipping commit."
else
  git commit -m "dotfiles: save $(date +%Y-%m-%d_%H%M)"
  echo ""
  echo "=== Push to origin ==="
  if git remote get-url origin &>/dev/null; then
    git push
  else
    echo "No remote configured. Commit saved locally."
  fi
fi

echo ""
echo "Done."
