export PATH="/opt/homebrew/opt/postgresql@16/bin:$PATH"
export PATH="$(brew --prefix ruby)/bin:$PATH"

export ANDROID_HOME=/Users/shoponyou/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
export PATH="$PATH:$HOME/.rvm/bin"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

alias c="code"

alias projet="
    echo ' ';
    cd /Users/shoponyou/Documents/projet;
    ls;
    echo ' ';
    echo 'use c <projet-name>';
    echo ' ';
"

alias done-generate="/Users/shoponyou/scripts_bash/generate_commit_report.sh"

alias conf-alias="c /Users/shoponyou/.zshrc"
alias conf-scripts="c /Users/shoponyou/scripts_bash"

alias config-alias="c /Users/shoponyou/.zshrc"
alias config-scripts="c /Users/shoponyou/scripts_bash"
# pnpm
export PNPM_HOME="/Users/shoponyou/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
