#!/bin/bash
# save.sh — Copy current configs into ~/.dotfiles/ and commit+push
set -e

DOTFILES="$HOME/.dotfiles"

# Safe copy: skip if source and dest point to the same file (via symlink)
safe_cp() {
  local src="$1" dst="$2"
  # If dst is a directory, append src's basename
  if [ -d "$dst" ]; then
    dst="$dst/$(basename "$src")"
  fi
  if [ "$src" -ef "$dst" ]; then
    return 0  # same file, skip
  fi
  cp -a "$src" "$dst"
} 

safe_cp_dir() {
  local src_dir="$1" dst_dir="$2" pattern="${3:-*}"
  mkdir -p "$dst_dir"
  for f in "$src_dir"/$pattern; do
    [ -f "$f" ] || [ -d "$f" ] || continue
    b="$(basename "$f")"
    [[ "$b" == *.bak.* ]] || [[ "$b" == *.bak[0-9]* ]] || [[ "$b" == *.bak_* ]] || safe_cp "$f" "$dst_dir/"
  done
}

echo "=== Copying configs to $DOTFILES ==="

# Hyprland
echo "[hypr]"
mkdir -p "$DOTFILES/.config/hypr"
safe_cp_dir "$HOME/.config/hypr" "$DOTFILES/.config/hypr" "*.conf"
safe_cp "$HOME/.config/hypr/hy3.conf" "$DOTFILES/.config/hypr/hy3.conf"
safe_cp "$HOME/.config/hypr/hy3-layout-watch.sh" "$DOTFILES/.config/hypr/hy3-layout-watch.sh"

# Waybar
echo "[waybar]"
safe_cp_dir "$HOME/.config/waybar" "$DOTFILES/.config/waybar"

# Walker
echo "[walker]"
mkdir -p "$DOTFILES/.config/walker"
safe_cp "$HOME/.config/walker/config.toml" "$DOTFILES/.config/walker/config.toml"

# SwayOSD
echo "[swayosd]"
safe_cp_dir "$HOME/.config/swayosd" "$DOTFILES/.config/swayosd"

# Btop
echo "[btop]"
mkdir -p "$DOTFILES/.config/btop"
safe_cp "$HOME/.config/btop/btop.conf" "$DOTFILES/.config/btop/btop.conf"

# Fastfetch
echo "[fastfetch]"
safe_cp_dir "$HOME/.config/fastfetch" "$DOTFILES/.config/fastfetch"

# Terminals
echo "[terminals]"
safe_cp "$HOME/.config/alacritty/alacritty.toml" "$DOTFILES/.config/alacritty/alacritty.toml"
safe_cp "$HOME/.config/ghostty/config" "$DOTFILES/.config/ghostty/config"
safe_cp "$HOME/.config/foot/foot.ini" "$DOTFILES/.config/foot/foot.ini"

# Systemd user services
echo "[systemd]"
mkdir -p "$DOTFILES/.config/systemd/user"
for f in "$HOME/.config/systemd/user/"*.service "$HOME/.config/systemd/user/"*.timer; do
  [ -f "$f" ] || continue
  # Skip symlinks to /dev/null (Nextcloud noise)
  [ -L "$f" ] && [ "$(readlink "$f")" = "/dev/null" ] && continue
  safe_cp "$f" "$DOTFILES/.config/systemd/user/"
done
for d in "$HOME/.config/systemd/user/"*.service.d; do
  [ -d "$d" ] || continue
  safe_cp "$d" "$DOTFILES/.config/systemd/user/"
done

# Autostart
echo "[autostart]"
mkdir -p "$DOTFILES/.config/autostart"
safe_cp_dir "$HOME/.config/autostart" "$DOTFILES/.config/autostart" "*.desktop"

# Environment
echo "[environment]"
safe_cp_dir "$HOME/.config/environment.d" "$DOTFILES/.config/environment.d"

# Chromium flags
safe_cp "$HOME/.config/chromium-flags.conf" "$DOTFILES/.config/chromium-flags.conf"

# Omarchy hooks
echo "[omarchy hooks]"
safe_cp_dir "$HOME/.config/omarchy/hooks" "$DOTFILES/.config/omarchy/hooks"

# Omarchy custom theme
echo "[omarchy theme harbor]"
safe_cp_dir "$HOME/.config/omarchy/themes/harbor" "$DOTFILES/.config/omarchy/themes/harbor"
for d in "$HOME/.config/omarchy/themes/harbor/backgrounds/"*; do
  [ -f "$d" ] && safe_cp "$d" "$DOTFILES/.config/omarchy/themes/harbor/backgrounds/" || true
done

# Omarchy extensions
echo "[omarchy extensions]"
safe_cp_dir "$HOME/.config/omarchy/extensions" "$DOTFILES/.config/omarchy/extensions"

# Omarchy branding
echo "[omarchy branding]"
safe_cp_dir "$HOME/.config/omarchy/branding" "$DOTFILES/.config/omarchy/branding"

# Custom scripts
echo "[scripts]"
mkdir -p "$DOTFILES/.local/bin"
for f in teams-jiggler teams-jiggler-status teams-jiggler-toggle teams-jiggler-off \
         nextcloud-external-guard neon-pilot-app omniroute; do
  [ -f "$HOME/.local/bin/$f" ] && safe_cp "$HOME/.local/bin/$f" "$DOTFILES/.local/bin/$f" || true
done

echo ""
echo "=== Git add + commit ==="
cd "$DOTFILES"

# Update .gitignore
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
