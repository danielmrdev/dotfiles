#!/bin/bash
# restore.sh — Restore tracked config from ~/.dotfiles to original locations
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

  # Refuse non-empty directories: `ln -s target existing-dir` would create a
  # nested link inside it instead of replacing the destination.
  if [ -L "$linkpath" ] || [ -f "$linkpath" ]; then
    rm -f "$linkpath"
  elif [ -d "$linkpath" ]; then
    if find "$linkpath" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
      echo "  ERROR (destination directory is not empty): $linkpath" >&2
      return 1
    fi
    rmdir "$linkpath"
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

# Copy custom mod files: Herdr rejects mod imports resolving through symlinks outside its app directory.
copy_tree_files() {
  local source_rel="$1" destdir="$2" srcdir="$DOTFILES/$1" file rel base dest
  [ -d "$srcdir" ] || return 0
  while IFS= read -r -d '' file; do
    rel="${file#"$srcdir"/}"
    base="$(basename "$file")"
    case "/$rel/" in
      */node_modules/*|*/.state/*|*/.git/*) continue ;;
    esac
    [[ "$base" == "jsconfig.json" || "$base" == *.d.ts ]] && continue
    [[ "$base" == *.bak.* || "$base" == *.bak[0-9]* || "$base" == *.bak_* ]] && continue
    dest="$destdir/$rel"
    mkdir -p "$(dirname "$dest")"
    [ ! -L "$dest" ] || rm -f "$dest"
    cp -a "$file" "$dest"
  done < <(find "$srcdir" -type f -print0)
}

echo "=== Restoring tracked config ==="

# Home-wide agent context stays separate from this repo's AGENTS.md.
link ".agents/context/AGENTS.md" "$HOME/AGENTS.md"

# Shell
link ".zshrc"                    "$HOME/.zshrc"
link ".p10k.zsh"                 "$HOME/.p10k.zsh"

# Hyprland
link_all ".config/hypr"    "$HOME/.config/hypr"

# Hyprshell (window switcher, SUPER+TAB)
link ".config/hyprshell/config.ron" "$HOME/.config/hyprshell/config.ron"
link ".config/hyprshell/styles.css" "$HOME/.config/hyprshell/styles.css"

# Omarchy shell (bar layout, idle)
link ".config/omarchy/shell.json" "$HOME/.config/omarchy/shell.json"

# Omarchy shell plugins (customized clones; git-installed plugins are handled by install.sh)
link_all ".config/omarchy/plugins" "$HOME/.config/omarchy/plugins"

# PipeWire AirPlay
link ".config/pipewire/pipewire.conf.d/raop-discover.conf" "$HOME/.config/pipewire/pipewire.conf.d/raop-discover.conf"
link ".config/pipewire/pipewire.conf.d/oficina-stereo.conf" "$HOME/.config/pipewire/pipewire.conf.d/oficina-stereo.conf"

# Btop
link ".config/btop/btop.conf"    "$HOME/.config/btop/btop.conf"

# Fastfetch
link_all ".config/fastfetch" "$HOME/.config/fastfetch"

# Terminal
link ".config/alacritty/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml" 2>/dev/null || true
link ".config/foot/foot.ini" "$HOME/.config/foot/foot.ini" 2>/dev/null || true
link ".local/share/icons/foot.svg" "$HOME/.local/share/icons/foot.svg" 2>/dev/null || true

# Fresh terminal IDE
link ".config/fresh/config.json" "$HOME/.config/fresh/config.json" 2>/dev/null || true

# Systemd user services
link_all ".config/systemd/user" "$HOME/.config/systemd/user" "*.service"
link_all ".config/systemd/user" "$HOME/.config/systemd/user" "*.timer"
link_all ".config/systemd/user" "$HOME/.config/systemd/user" "*.path"
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

# Herdr app: user config and custom mods; runtime state, bundled assets and current theme stay local/generated.
link ".config/herdr-app/keys.json" "$HOME/.config/herdr-app/keys.json"
if [ -f "$DOTFILES/.config/herdr-app/settings.json" ]; then
  chmod 600 "$DOTFILES/.config/herdr-app/settings.json"
fi
link ".config/herdr-app/settings.json" "$HOME/.config/herdr-app/settings.json"
link ".config/herdr-app/programs.json" "$HOME/.config/herdr-app/programs.json"
link_all ".config/herdr-app/layouts" "$HOME/.config/herdr-app/layouts" "*.json"
link_all ".config/herdr-app/layouts" "$HOME/.config/herdr-app/layouts" "*.svg"
# AppAssets refuses preview symlinks that escape appHome; keep this asset in-root.
preview_src="$DOTFILES/.config/herdr-app/layouts/herdr-t3.svg"
preview_dest="$HOME/.config/herdr-app/layouts/herdr-t3.svg"
if [ -f "$preview_src" ]; then
  if [ -L "$preview_dest" ] || [ -f "$preview_dest" ]; then
    rm -f "$preview_dest"
  elif [ -d "$preview_dest" ]; then
    if find "$preview_dest" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
      echo "  ERROR (destination directory is not empty): $preview_dest" >&2
      exit 1
    fi
    rmdir "$preview_dest"
  fi
  cp -a "$preview_src" "$preview_dest"
  echo "  COPY .config/herdr-app/layouts/herdr-t3.svg → $preview_dest"
fi
link_all ".config/herdr-app/themes" "$HOME/.config/herdr-app/themes" "*.json"
for moddir in "$DOTFILES/.config/herdr-app/mods/"*; do
  [ -d "$moddir" ] || continue
  mod="$(basename "$moddir")"
  copy_tree_files ".config/herdr-app/mods/$mod" "$HOME/.config/herdr-app/mods/$mod"
done
link ".config/herdr-app/sync-omarchy-theme.py" "$HOME/.config/herdr-app/sync-omarchy-theme.py"
link ".local/share/applications/herdr-app.desktop" "$HOME/.local/share/applications/herdr-app.desktop"
if [ -f "$HOME/.local/state/omarchy/current/theme/colors.toml" ] && command -v omarchy-theme-color >/dev/null 2>&1; then
  if ! python3 "$HOME/.config/herdr-app/sync-omarchy-theme.py"; then
    echo "  WARN could not sync Herdr theme from Omarchy's current palette" >&2
  fi
fi

# Omarchy extensions
link_all ".config/omarchy/extensions" "$HOME/.config/omarchy/extensions"

# Omarchy branding
link_all ".config/omarchy/branding" "$HOME/.config/omarchy/branding"

# Custom scripts, including update-fingerprint-libs. The package manifest stays
# in the repository at packages/aur-fingerprint.txt and is consumed by install.sh
# and the restored helper.
link_all ".local/bin" "$HOME/.local/bin"

# Omarchy → Zen Browser theme sync
# Link directory, not individual files: sync.sh rejects final-file symlinks.
link ".local/share/omarchy-zen-sync" "$HOME/.local/share/omarchy-zen-sync"

# Agent skills (whole dir symlink)
link_with_parent() {
  local target="$1" linkpath="$2"
  if [ ! -e "$target" ] && [ ! -L "$target" ]; then
    echo "  SKIP (source missing): $target"
    return
  fi

  mkdir -p "$(dirname "$linkpath")"
  if [ -L "$linkpath" ] || [ -f "$linkpath" ]; then
    rm -f "$linkpath"
  elif [ -d "$linkpath" ]; then
    if find "$linkpath" -mindepth 1 -maxdepth 1 -print -quit | grep -q .; then
      echo "  ERROR (destination directory is not empty): $linkpath" >&2
      return 1
    fi
    rmdir "$linkpath"
  fi

  ln -s "$target" "$linkpath"
  echo "  LINK $target → $linkpath"
}
link_with_parent "$DOTFILES/.agents/skills" "$HOME/.agents/skills"

# Pi agent skills
link_with_parent "$DOTFILES/.agents/skills/sudo-askpass" "$HOME/.pi/agent/skills/sudo-askpass"

# Pith config (db/ intentionally not tracked)
link_with_parent "$DOTFILES/.pith/skills" "$HOME/.pith/skills"
link_with_parent "$DOTFILES/.pith/memory" "$HOME/.pith/memory"

# ONLYOFFICE scaled desktop launcher
link ".local/share/applications/onlyoffice-desktopeditors.desktop" "$HOME/.local/share/applications/onlyoffice-desktopeditors.desktop"

# TTT terminal editor launcher
link ".local/share/applications/ttt.desktop" "$HOME/.local/share/applications/ttt.desktop"

# Tizen Studio GTK2/SWT launchers
link ".local/share/applications/tizen-studio-ide.desktop" "$HOME/.local/share/applications/tizen-studio-ide.desktop"
link ".local/share/applications/tizen-studio-packagemanager.desktop" "$HOME/.local/share/applications/tizen-studio-packagemanager.desktop"
link ".local/share/applications/tizen-studio-devicemanager.desktop" "$HOME/.local/share/applications/tizen-studio-devicemanager.desktop"

# Web app desktop files and icons
echo "  LINK webapp desktop files + icons"
mkdir -p "$HOME/.local/share/applications/icons"
link ".local/share/applications/Outlook.desktop" "$HOME/.local/share/applications/Outlook.desktop"
link ".local/share/applications/Teams.desktop" "$HOME/.local/share/applications/Teams.desktop"
link ".local/share/applications/OneDrive.desktop" "$HOME/.local/share/applications/OneDrive.desktop"
link ".local/share/applications/Hache.desktop" "$HOME/.local/share/applications/Hache.desktop"
link ".local/share/applications/icons/Outlook.png" "$HOME/.local/share/applications/icons/Outlook.png"
link ".local/share/applications/icons/Teams.png" "$HOME/.local/share/applications/icons/Teams.png"
link ".local/share/applications/icons/OneDrive.png" "$HOME/.local/share/applications/icons/OneDrive.png"
link ".local/share/applications/icons/Hache.png" "$HOME/.local/share/applications/icons/Hache.png"
link ".local/share/applications/Tailscale.desktop" "$HOME/.local/share/applications/Tailscale.desktop"
link ".local/share/applications/icons/Tailscale.png" "$HOME/.local/share/applications/icons/Tailscale.png"

echo ""
echo "=== System files (PAM + fingerprint script) ==="
echo ""
echo "These need root. Run after restore.sh:"
echo ""
echo "  sudo cp \"$DOTFILES/.local/bin/lid-is-open\" /usr/local/bin/lid-is-open"
echo "  sudo chmod +x /usr/local/bin/lid-is-open"
echo "  sudo cp \"$DOTFILES/etc/pam.d/sudo\" /etc/pam.d/sudo"
echo "  sudo cp \"$DOTFILES/etc/pam.d/polkit-1\" /etc/pam.d/polkit-1"
echo ""
echo "=== Enabling Git hooks ==="
git -C "$DOTFILES" config core.hooksPath .githooks

echo "=== Reloading systemd ==="
systemctl --user daemon-reload 2>/dev/null || true

echo ""
echo "=== Done ==="
echo "Symlinks created. You may want to:"
echo "  omarchy restart shell"
echo "  hyprctl reload"
echo "  source ~/.zshrc"
