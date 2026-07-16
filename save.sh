#!/bin/bash
# save.sh — Copy configs into ~/.dotfiles/ and commit+push
set -e

DOTFILES="$HOME/.dotfiles"

# Safe copy: skip if source and dest are the same file (symlink scenario)
safe_cp() {
  local src="$1" dst="$2"
  # If dst is a directory, append src's basename
  if [ -d "$dst" ]; then
    dst="$dst/$(basename "$src")"
  fi
  # Skip if same file (source is a symlink to dest inside DOTFILES)
  if [ -f "$src" ] && [ -f "$dst" ] && [ "$src" -ef "$dst" ]; then
    return 0
  fi
  cp -a "$src" "$dst"
}

# Copy all regular files from src_dir into dst_dir (skip dirs, .bak)
safe_cp_dir() {
  local src_dir="$1" dst_dir="$2" pattern="${3:-*}"
  mkdir -p "$dst_dir"
  for entry in "$src_dir"/$pattern; do
    [ -e "$entry" ] || continue
    b="$(basename "$entry")"
    [[ "$b" == *.bak.* ]] || [[ "$b" == *.bak[0-9]* ]] || [[ "$b" == *.bak_* ]] && continue
    # Only regular files — skip dirs (they're symlinks into the repo)
    [ -f "$entry" ] || continue
    safe_cp "$entry" "$dst_dir/"
  done
}

echo "=== Copying configs to $DOTFILES ==="

# Hyprland
echo "[hypr]"
mkdir -p "$DOTFILES/.config/hypr"
safe_cp_dir "$HOME/.config/hypr" "$DOTFILES/.config/hypr" "*.conf"
safe_cp "$HOME/.config/hypr/hy3-layout-watch.sh" "$DOTFILES/.config/hypr/hy3-layout-watch.sh"

# Hyprshell
echo "[hyprshell]"
mkdir -p "$DOTFILES/.config/hyprshell"
safe_cp "$HOME/.config/hyprshell/config.ron" "$DOTFILES/.config/hyprshell/config.ron"
safe_cp "$HOME/.config/hyprshell/styles.css" "$DOTFILES/.config/hyprshell/styles.css"

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
# Service drop-in overrides (copy as-is, they're small config dirs)
for d in "$HOME/.config/systemd/user/"*.service.d; do
  [ -d "$d" ] || continue
  # Skip if already symlinked into our repo
  b="$(basename "$d")"
  dst="$DOTFILES/.config/systemd/user/$b"
  if [ -d "$dst" ] && [ "$d" -ef "$dst" ]; then
    continue  # same dir via symlink
  fi
  cp -a "$d" "$dst"
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

# Omarchy hooks (only regular files, skip dir symlinks)
echo "[omarchy hooks]"
mkdir -p "$DOTFILES/.config/omarchy/hooks"
for entry in "$HOME/.config/omarchy/hooks/"*; do
  [ -f "$entry" ] || continue  # skip dirs (they're symlinks into repo)
  b="$(basename "$entry")"
  [[ "$b" == *.sample ]] && continue  # sample files not needed
  safe_cp "$entry" "$DOTFILES/.config/omarchy/hooks/"
done

# Omarchy custom theme (files only)
echo "[omarchy theme harbor]"
for entry in "$HOME/.config/omarchy/themes/harbor/"*; do
  [ -f "$entry" ] || continue
  safe_cp "$entry" "$DOTFILES/.config/omarchy/themes/harbor/"
done
# Backgrounds (files only)
for entry in "$HOME/.config/omarchy/themes/harbor/backgrounds/"*; do
  [ -f "$entry" ] || continue
  safe_cp "$entry" "$DOTFILES/.config/omarchy/themes/harbor/backgrounds/"
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
for s in teams-jiggler teams-jiggler-status teams-jiggler-toggle teams-jiggler-off \
         nextcloud-external-guard neon-pilot-app omniroute omarchy-webapp-patch save-dotfiles restore-dotfiles; do
  [ -f "$HOME/.local/bin/$s" ] || continue
  safe_cp "$HOME/.local/bin/$s" "$DOTFILES/.local/bin/"
done

# Web app desktop files and icons (created by omarchy-webapp-install)
echo "[webapps]"
mkdir -p "$DOTFILES/.local/share/applications/icons"
safe_cp "$HOME/.local/share/applications/Outlook.desktop" "$DOTFILES/.local/share/applications/Outlook.desktop"
safe_cp "$HOME/.local/share/applications/Teams.desktop" "$DOTFILES/.local/share/applications/Teams.desktop"
safe_cp "$HOME/.local/share/applications/WhatsApp.desktop" "$DOTFILES/.local/share/applications/WhatsApp.desktop"
safe_cp "$HOME/.local/share/applications/Hache.desktop" "$DOTFILES/.local/share/applications/Hache.desktop"
safe_cp "$HOME/.local/share/applications/icons/Outlook.png" "$DOTFILES/.local/share/applications/icons/Outlook.png"
safe_cp "$HOME/.local/share/applications/icons/Teams.png" "$DOTFILES/.local/share/applications/icons/Teams.png"
safe_cp "$HOME/.local/share/applications/icons/WhatsApp.png" "$DOTFILES/.local/share/applications/icons/WhatsApp.png"
safe_cp "$HOME/.local/share/applications/icons/Hache.png" "$DOTFILES/.local/share/applications/icons/Hache.png"
safe_cp "$HOME/.local/share/applications/Tailscale.desktop" "$DOTFILES/.local/share/applications/Tailscale.desktop"
safe_cp "$HOME/.local/share/applications/icons/Tailscale.png" "$DOTFILES/.local/share/applications/icons/Tailscale.png"

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
