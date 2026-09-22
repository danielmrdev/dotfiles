# Load Composer tools
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Load Node global installed binaries
export PATH="$HOME/.node/bin:$PATH"

# Use project specific binaries before global ones
export PATH="node_modules/.bin:vendor/bin:$PATH"

# beautiful-pi has a local Pi CLI peer for development; use global Pi here.
pi() {
  if [[ "$PWD" == "$HOME/Projects/beautiful-pi" || "$PWD" == "$HOME/Projects/beautiful-pi/"* ]]; then
    "$HOME/.local/bin/pi" "$@"
  else
    command pi "$@"
  fi
}

# Make sure coreutils are loaded before system commands
# I've disabled this for now because I only use "ls" which is
# referenced in my aliases.zsh file directly.
#export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"

# Local bin directories before anything else
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# Load custom commands
export PATH="$DOTFILES/bin:$PATH"

# Home bin
export PATH="$HOME/bin:$PATH"

# NPM global
export PATH=~/.npm-global/bin:$PATH

# Bun
export PATH="$BUN_INSTALL/bin:$PATH"

# Local bin
export PATH="$PATH:$HOME/.local/bin"

# Platform-specific paths
if [[ "$(uname -s)" == "Darwin" ]]; then
  export JAVA_HOME=/opt/homebrew/opt/openjdk
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/opt/homebrew/opt/openjdk/bin:$PATH"
  export PATH="$PATH:/Users/danielmunoz/.codeium/windsurf/bin:/Users/danielmunoz/.spicetify"
fi
