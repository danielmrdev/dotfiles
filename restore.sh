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

  # Remove existing file/symlink/dir at destination
  if [ -L "$linkpath" ] || [ -f "$linkpath" ]; then
    rm -f "$linkpath"
  elif [ -d "$linkpath" ]; then
    # Only remove if it's not a critical system dir
    rmdir "$linkpath" 2>/dev/null || true
  fi

  ln -s "$fulltarget" "$linkpath"
  echo "  LINK $target → $linkpath"
}

# Helper: link all files in a dir (with .bak filter)
link_all() {
  local srcdir="$DOTFILES/$1"
  local destdir="$2"
  local pattern="${3:-*}"
  for f in "$srcdir"/$pattern; do
    [ -f "$f" ] || [ -d "$f" ] || continue
    b="$(basename "$f")"
    [[ "$b" == *.bak.* ]] && continue
    [[ "$b" == *.bak_* ]] && continue
    [[ "$b" == *.bak[0-9]* ]] && continue
    link "$1/$b" "$destdir/$b"
  done
}

echo "=== Creating symlinks ==="

# Shell
link ".zshrc"                    "$HOME/.zshrc"
link ".p10k.zsh"                 "$HOME/.p10k.zsh"

# Hyprland
link_all ".config/hypr"    "$HOME/.config/hypr"

# Waybar
link_all ".config/waybar"  "$HOME/.config/waybar"

# Walker
link ".config/walker/config.toml" "$HOME/.config/walker/config.toml"

# SwayOSD
link_all ".config/swayosd" "$HOME/.config/swayosd"

# Btop
link ".config/btop/btop.conf"    "$HOME/.config/btop/btop.conf"

# Fastfetch
link_all ".config/fastfetch" "$HOME/.config/fastfetch"

# Terminals
link ".config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml" 2>/dev/null || true
link ".config/ghostty/config"           "$HOME/.config/ghostty/config" 2>/dev/null || true
link ".config/foot/foot.ini"            "$HOME/.config/foot/foot.ini" 2>/dev/null || true

# Systemd user services
link_all ".config/systemd/user" "$HOME/.config/systemd/user" "*.service"
link_all ".config/systemd/user" "$HOME/.config/systemd/user" "*.timer"
for d in "$DOTFILES/.config/systemd/user/"*.service.d; do
  [ -d "$d" ] || continue
  b="$(basename "$d")"
  link ".config/systemd/user/$b" "$HOME/.config/systemd/user/$b"
done

# Autostart
link_all ".config/autostart" "$HOME/.config/autostart" "*.desktop"

# Environment
for f in "$DOTFILES/.config/environment.d/"*; do
  b="$(basename "$f")"
  [ "$b" = "*" ] && continue
  link ".config/environment.d/$b" "$HOME/.config/environment.d/$b"
done

# Chromium flags
link ".config/chromium-flags.conf" "$HOME/.config/chromium-flags.conf" 2>/dev/null || true

# Omarchy hooks
link_all ".config/omarchy/hooks" "$HOME/.config/omarchy/hooks"

# Omarchy custom theme (files + backgrounds dir)
link_all ".config/omarchy/themes/harbor" "$HOME/.config/omarchy/themes/harbor"
for d in "$DOTFILES/.config/omarchy/themes/harbor/backgrounds/"*; do
  [ -f "$d" ] || continue
  b="$(basename "$d")"
  link ".config/omarchy/themes/harbor/backgrounds/$b" "$HOME/.config/omarchy/themes/harbor/backgrounds/$b"
done

# Omarchy extensions
link_all ".config/omarchy/extensions" "$HOME/.config/omarchy/extensions"

# Omarchy branding
link_all ".config/omarchy/branding" "$HOME/.config/omarchy/branding"

# Custom scripts
link_all ".local/bin" "$HOME/.local/bin"

echo ""
echo "=== System files (PAM + fingerprint script) ==="
echo ""
echo "These need root. Run after restore.sh:"
echo ""
echo '  sudo cp "$DOTFILES/.local/bin/lid-is-open" /usr/local/bin/lid-is-open'
echo '  sudo chmod +x /usr/local/bin/lid-is-open'
echo '  sudo cp "$DOTFILES/etc/pam.d/sudo" /etc/pam.d/sudo'
echo '  sudo cp "$DOTFILES/etc/pam.d/polkit-1" /etc/pam.d/polkit-1'
echo ""
echo "=== Reloading systemd ==="
systemctl --user daemon-reload 2>/dev/null || true

echo ""
echo "=== Done ==="
echo "Symlinks created. You may want to:"
echo "  omarchy restart waybar"
echo "  hyprctl reload"
echo "  source ~/.zshrc"
