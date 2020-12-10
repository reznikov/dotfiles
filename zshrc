#!/bin/zsh

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER='open'
fi

export EDITOR=code

export PATH="/usr/local/sbin:$PATH"

export CLICOLOR=1
export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES

autoload -U promptinit; promptinit
prompt pure

source /usr/local/share/antigen/antigen.zsh

antigen bundle robbyrussell/oh-my-zsh plugins/git

antigen bundle zsh-users/zsh-completions
antigen bundle zsh-users/zsh-autosuggestions
antigen bundle zsh-users/zsh-syntax-highlighting

antigen apply

zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''

zstyle ':completion:*' verbose yes
zstyle ':completion:*:descriptions' format $'\n%F{blue}Completing %d%f ✨\n'
zstyle ':completion:functions' ignored-patterns '_*'


# Aliases

alias src="source $HOME/.zshrc"

alias weather="curl https://wttr.in/riga\?FQ"

alias ll="ls -lhFG"
alias la="ls -lahFG"

alias -s {json,js,ts,html}=$EDITOR

alias bubu="brew update && brew upgrade && brew cleanup"

flushdns () {
  sudo killall -HUP mDNSResponder
  sudo killall mDNSResponderHelper
  sudo dscacheutil -flushcache
}

clear_history () {
  local HISTSIZE=0;
}
