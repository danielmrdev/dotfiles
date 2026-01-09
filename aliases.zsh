# Shortcuts
alias c="clear"
alias cat="bat"
alias copyssh="pbcopy < $HOME/.ssh/id_rsa.pub"
alias reload="source $HOME/.zshrc"
alias reloaddns="dscacheutil -flushcache && sudo killall -HUP mDNSResponder"
alias ls="lsd"
alias myip="ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'"
alias ip="curl ifconfig.co"
# alias updateip="php $HOME/.dotfiles/dns-auto-updater/do-dns-auto-updater.php"

# Directories
alias dotfiles="cd $DOTFILES"
alias library="cd $HOME/Library"

# Laravel
alias art="php artisan"
alias t="clear && phpunit"
alias p="clear && ./vendor/bin/pest"

# Kill processes
function kill () {
  command kill -KILL $(pidof "$@")
}

# Composer Package development
composer-link() {
  repositoryName=${3:-local}

  composer config repositories.$repositoryName '{"type": "path", "url": "'$1'", "options": {"symlink": true}}' --file composer.json
  composer require $2 @dev
}
# Add HAYAI dependency to a project
composer-hayai() {
  branchName=dev-${1:-master}

  composer config repositories.laravel-hayai '{"type": "vcs", "url": "git@bitbucket.org:d2pro/laravel-hayai.git"}' --file composer.json
  composer require d2pro/laravel-hayai:$branchName
}

# Git
alias gaa="git add --all"
alias gb="git branch"
alias gcb="git checkout -b"
alias gca="git commit --amend --no-edit"
alias gcam="git commit --all -m"
alias gcm="git commit -m"
alias gco="git checkout"
alias gd="git diff"
alias gfa="git fetch --all --tags --prune"
alias gl="git log --oneline --graph --decorate --all"
alias glo="git pull origin"
alias glola="git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ar) %C(bold blue)<%an>%Creset' --all"
alias gm="git merge"
alias gpo="git push origin"
alias gr="git remote"
alias gsb="git status --short --branch"
# Be careful!!
alias dracarys="git reset --hard && git clean -df"
# Made a complete re-Tagging to the last/current commit
retag() {
  git tag --delete $1
  git push --delete origin $1
  git tag $1
  git push origin --tags
}
# Quickly commit and push changes
wip() {
  msg=${1:-🚧 work in progress 🤗}

  git add --all
  git commit -a -m $msg
  git push origin
}

# Visual Studio Code
alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"

# Help (colored with bat)
help() {
    "$@" --help 2>&1 | bat --plain --language=help
}
alias -g -- -h='-h 2>&1 | bat --language=help --style=plain'
alias -g -- --help='--help 2>&1 | bat --language=help --style=plain'

# GLM
glm() {
  export ANTHROPIC_AUTH_TOKEN="56e2c642e29842f783e5acdd67be96b1.JviO8WFjKbuuL3A2"
  export ANTHROPIC_BASE_URL="https://api.z.ai/api/anthropic"
  export API_TIMEOUT_MS="3000000"
  export ANTHROPIC_DEFAULT_HAIKU_MODEL="glm-4.5-air"
  export ANTHROPIC_DEFAULT_SONNET_MODEL="glm-4.6"
  export ANTHROPIC_DEFAULT_OPUS_MODEL="glm-4.6"
  claude "$@"
}
ccc() {
  unset ANTHROPIC_AUTH_TOKEN
  unset ANTHROPIC_BASE_URL
  unset API_TIMEOUT_MS
  unset ANTHROPIC_DEFAULT_HAIKU_MODEL
  unset ANTHROPIC_DEFAULT_SONNET_MODEL
  unset ANTHROPIC_DEFAULT_OPUS_MODEL
  claude "$@"
}
