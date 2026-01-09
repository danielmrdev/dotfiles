# Load Composer tools
export PATH="$HOME/.composer/vendor/bin:$PATH"

# Load Node global installed binaries
export PATH="$HOME/.node/bin:$PATH"

# Use project specific binaries before global ones
export PATH="node_modules/.bin:vendor/bin:$PATH"

# Make sure coreutils are loaded before system commands
# I've disabled this for now because I only use "ls" which is
# referenced in my aliases.zsh file directly.
#export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"

# Local bin directories before anything else
export PATH="/usr/local/bin:/usr/local/sbin:$PATH"

# Load custom commands
export PATH="$DOTFILES/bin:$PATH"

# Brew preference
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# JAVA
export JAVA_HOME=/opt/homebrew/opt/openjdk
# Local bin
export PATH="$PATH:/Users/danielmunoz/.local/bin"

# Codeium Windsurf
export PATH="/Users/danielmunoz/.codeium/windsurf/bin:$PATH"

# Java
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# Home bin
export PATH="$HOME/bin:$PATH"

# NPM global
export PATH=~/.npm-global/bin:$PATH

# Bun
export PATH="$BUN_INSTALL/bin:$PATH"

# Spicetify
export PATH=$PATH:/Users/danielmunoz/.spicetify

