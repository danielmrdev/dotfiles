#!/bin/bash
# restore.sh — Create symlinks from ~/.dotfiles/ to original locations
# Run AFTER cloning dotfiles repo to a (new) machine.
set -e

DOTFILES="$HOME/.dotfiles"

link() {
  local target="$1"   # path relative to DOTFILES
  local linkpath="$2" # full path of the symlink to create
  local fulltarget="$DOTFILES/$target"

  if [ ! -e "$fulltarget" ] && [ ! -L "$fulltarget" ]; then
    echo "  SKIP (source missing): $target"
    return
  fi

  mkdir -p "$(dirname "$linkpath")"

  # Remove existing file/symlink at destination
  if [ -e "$linkpath" ] || [ -L "$linkpath" ]; then
    rm -f "$linkpath"
  fi

  ln -s "$fulltarget" "$linkpath"
  echo "  LINK $target → $linkpath"
}

echo "=== Creating symlinks ==="

# Shell
link ".zshrc"                    "$HOME/.zshrc"
link ".p10k.zsh"                 "$HOME/.p10k.zsh"
link "aliases.zsh"               "$HOME/.dotfiles/aliases.zsh"
link "path.zsh"                  "$HOME/.dotfiles/path.zsh"

# Hyprland
for f in "$DOTFILES/.config/hypr/"*.conf; do
  b="$(basename "$f")"
  link ".config/hypr/$b"         "$HOME/.config/hypr/$b"
done

# Waybar
for f in "$DOTFILES/.config/waybar/"*; do
  b="$(basename "$f")"
  link ".config/waybar/$b"       "$HOME/.config/waybar/$b"
done

# Walker
link ".config/walker/config.toml" "$HOME/.config/walker/config.toml"

# SwayOSD
for f in "$DOTFILES/.config/swayosd/"*; do
  b="$(basename "$f")"
  link ".config/swayosd/$b"      "$HOME/.config/swayosd/$b"
done

# Btop
link ".config/btop/btop.conf"    "$HOME/.config/btop/btop.conf"

# Fastfetch
for f in "$DOTFILES/.config/fastfetch/"*; do
  b="$(basename "$f")"
  [ "$b" = "*.bak.*" ] && continue
  link ".config/fastfetch/$b"    "$HOME/.config/fastfetch/$b"
done

# Terminals
link ".config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml" 2>/dev/null || true
link ".config/ghostty/config"           "$HOME/.config/ghostty/config" 2>/dev/null || true
link ".config/foot/foot.ini"            "$HOME/.config/foot/foot.ini" 2>/dev/null || true

# Systemd user services
for f in "$DOTFILES/.config/systemd/user/"*.service "$DOTFILES/.config/systemd/user/"*.timer; do
  b="$(basename "$f")"
  link ".config/systemd/user/$b" "$HOME/.config/systemd/user/$b"
done
for d in "$DOTFILES/.config/systemd/user/"*.service.d; do
  [ -d "$d" ] || continue
  b="$(basename "$d")"
  link ".config/systemd/user/$b" "$HOME/.config/systemd/user/$b"
done

# Autostart
for f in "$DOTFILES/.config/autostart/"*.desktop; do
  b="$(basename "$f")"
  link ".config/autostart/$b"    "$HOME/.config/autostart/$b"
done

# Environment
for f in "$DOTFILES/.config/environment.d/"*; do
  b="$(basename "$f")"
  [ "$b" = "*" ] && continue
  link ".config/environment.d/$b" "$HOME/.config/environment.d/$b"
done

# Chromium flags
link ".config/chromium-flags.conf" "$HOME/.config/chromium-flags.conf" 2>/dev/null || true

# Omarchy hooks
for f in "$DOTFILES/.config/omarchy/hooks/"*; do
  b="$(basename "$f")"
  [ "$b" = "*" ] && continue
  link ".config/omarchy/hooks/$b" "$HOME/.config/omarchy/hooks/$b"
done

# Omarchy custom theme
for f in "$DOTFILES/.config/omarchy/themes/harbor/"*; do
  b="$(basename "$f")"
  [ -f "$f" ] && link ".config/omarchy/themes/harbor/$b" "$HOME/.config/omarchy/themes/harbor/$b" || true
done
# Also link background dir
if [ -d "$DOTFILES/.config/omarchy/themes/harbor/backgrounds" ]; then
  link ".config/omarchy/themes/harbor/backgrounds" "$HOME/.config/omarchy/themes/harbor/backgrounds" 2>/dev/null || true
fi

# Omarchy extensions
for f in "$DOTFILES/.config/omarchy/extensions/"*; do
  b="$(basename "$f")"
  [ "$b" = "*" ] && continue
  link ".config/omarchy/extensions/$b" "$HOME/.config/omarchy/extensions/$b"
done

# Omarchy branding
for f in "$DOTFILES/.config/omarchy/branding/"*; do
  b="$(basename "$f")"
  link ".config/omarchy/branding/$b" "$HOME/.config/omarchy/branding/$b"
done

# Custom scripts
for f in "$DOTFILES/.local/bin/"*; do
  b="$(basename "$f")"
  link ".local/bin/$b" "$HOME/.local/bin/$b"
done

echo ""
echo "=== Reloading systemd ==="
systemctl --user daemon-reload 2>/dev/null || true

echo ""
echo "=== Done ==="
echo "Symlinks created. You may want to:"
echo "  omarchy restart waybar"
echo "  hyprctl reload"
echo "  source ~/.zshrc"
