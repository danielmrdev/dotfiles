# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Prompt minimalista si estamos en VSCode (para evitar problemas con $? y temas AI)
if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  export PS1='$ '
  return
fi

# Path to your dotfiles installation.
export DOTFILES=$HOME/.dotfiles

# Node/pnpm installed via mise
export PATH="$HOME/.local/share/mise/installs/node/26.2.0/bin:$HOME/.local/bin:$PATH"

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

export XDEBUG_CONFIG="idekey=VSCODE"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Aliases para Claude Code móvil con Tailscale Magic DNS
alias claude-mobile='tmux new-session -A -s claude-mobile'
alias claude-attach='tmux attach-session -t claude-mobile'
alias claude-detach='tmux detach-client'

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="dd/mm/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
ZSH_CUSTOM=$DOTFILES

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(gitignore)

# ── Env vars needed also in non-interactive shells (pi/omp !!command, etc.) ──
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# GitHub Cli
export NODE_AUTH_TOKEN=cAgPagfk7BnZJWVyLXpbaHUGFrFBgC2gDIwE

# NPM publish
export NPM_TOKEN=b8face04-74a7-418e-86e5-033a0ee9eae2
export NPM_EMAIL=daniel@d2pro.es

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# pnpm
export PNPM_HOME="/home/daniel/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac

export PATH="$HOME/.npm-global/bin:$PATH"

# Skip oh-my-zsh if not interactive, or if called via `zsh -c` (pi/omp !!command).
# Uses ZSH_EXECUTION_STRING (set only by -c flag) instead of -t 0 to avoid
# a race where uwsm-app/daemon launch doesn't inherit a proper tty stdin.
[[ -o interactive && -z "$ZSH_EXECUTION_STRING" ]] || {
  source "$DOTFILES/aliases.zsh"
  source "$DOTFILES/path.zsh"
  return
}

# Activate Oh-My-Zsh
source "$ZSH/oh-my-zsh.sh"

# Aliases (also sourced in non-interactive path above)
source "$DOTFILES/aliases.zsh"
source "$DOTFILES/path.zsh"

# Powerlevel10k theme: use the standard oh-my-zsh custom theme path.
if [[ -f "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme" ]]; then
  source "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme"
elif [[ -f "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme.zwc" ]]; then
  source "$HOME/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme.zwc"
fi

# ZSH autosuggestions & syntax highlighting, if installed locally.
if [[ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
  source "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
if [[ -f "$HOME/.oh-my-zsh/custom/plugins/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh" ]]; then
  source "$HOME/.oh-my-zsh/custom/plugins/zsh-fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
fi

# iTerm2 shell integration (interactive only)
test -e "$HOME/.iterm2_shell_integration.zsh" && source "$HOME/.iterm2_shell_integration.zsh" || true

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# bun completions
[ -s "/home/daniel/.bun/_bun" ] && source "/home/daniel/.bun/_bun"
