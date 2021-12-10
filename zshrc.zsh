#!/bin/zsh

export DOTFILES="$HOME/dotfiles"

if [[ "$OSTYPE" == darwin* ]]; then
  export BROWSER="open"
fi

export EDITOR="code" # code is the default editor
export CLICOLOR=1 # color in terminal

export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES # enable tmux integration

setopt auto_cd # automatically change directory when dir name is typed

PATH="/usr/local/bin:/usr/local/sbin:$PATH" # add local bin to PATH
PATH="$PATH:$HOME/.cargo/bin" # cargo
export PATH

# History config

setopt append_history # append to the history file, don't overwrite it
setopt hist_expire_dups_first # expire duplicate entries first
setopt hist_fcntl_lock # lock the history file with fcntl()
setopt hist_ignore_all_dups # don't record all duplicates
setopt hist_lex_words # treat words as a lexical unit
setopt hist_reduce_blanks # remove repeated blank entries
setopt hist_save_no_dups # don't record all duplicates
setopt share_history # share history between sessions

# Homebrew config

#if [[ "$OSTYPE" == darwin* ]]; then
#  export BROWSER="open"
#fi

export HOMEBREW_BREWFILE="$DOTFILES/system/Brewfile"
export HOMEBREW_NO_ANALYTICS=1 # disable analytics
export HOMEBREW_NO_INSECURE_REDIRECT=1 # disable insecure redirects

if type brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}" # add brew's zsh functions
fi

# Load antigen & plugins

ANTIGEN_HOME=$(brew --prefix antigen)

source "$ANTIGEN_HOME/share/antigen/antigen.zsh"

antigen bundles <<EOBUNDLES
  zsh-users/zsh-syntax-highlighting # syntax highlighting bundle
  zsh-users/zsh-completions # additional completion definitions
  zsh-users/zsh-autosuggestions # additional suggestions
EOBUNDLES

#antigen theme spaceship-prompt/spaceship-prompt

antigen apply


# Load prompt

autoload -Uz promptinit
promptinit

export PURE_PROMPT_SYMBOL="λ"
export PURE_PROMPT_VICMD_SYMBOL="λ"

zstyle ':prompt:pure:prompt:success' color green

prompt pure


# Configure completion

zstyle ':completion:*' completer _complete _ignored _approximate
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
#zstyle ':completion:*' list-colors ''

zstyle ':completion:*' matcher-list 'm:{[:lower:]}={[:upper:]} m:{[:lower:][:upper:]}={[:upper:][:lower:]}'
zstyle ':completion:*' verbose yes
#zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*:descriptions' format $'\n%F{blue}Completing %d%f ✨\n'
zstyle ':completion:*:users' ignored-patterns '_*'
zstyle ':completion:functions' ignored-patterns '_*'
zstyle ':compinstall' filename "$HOME/.zshrc"

autoload -Uz compinit
compinit


# Lazy loading NVM

export NVM_DIR="$HOME/.nvm"
export NVM_SYMLINK_CURRENT=1 # use nvm's current version
NVM_HOME=$(brew --prefix nvm)

__lazynvm() {
  unset -f nvm node npm npx > /dev/null 2>&1
  source "$NVM_HOME/nvm.sh" # This loads nvm
  source "$NVM_HOME/etc/bash_completion.d/nvm" # This loads nvm bash_completion
}

nvm() {
  __lazynvm
  nvm "$@"
}

node() {
  __lazynvm
  node "$@"
}

npm() {
  __lazynvm
  npm "$@"
}

npm() {
  __lazynvm
  npx "$@"
}


# Configure aliases

alias ll="ls -lhFG" # list all files in long format
alias la="ls -lahFG" # list all files

alias -s {json,js,ts,html}="$EDITOR" # open files with default editor

alias d="docker"
alias g="git"

bubu () {
  echo "Updating homebrew packages..."
  brew update
  brew upgrade
  brew cleanup

  echo "Updating nvm & npm..."
  if [ -s "$NVM_HOME/nvm.sh" ]; then
    nvm install stable --reinstall-packages-from=current
    nvm install-latest-npm
  fi

  echo "Updating global npm packages.."
  npm update -g
}

pid () {
  ps -fe | grep "$1" | awk '{print $2}'
}

flushdns () {
  sudo killall -HUP mDNSResponder
  sudo killall mDNSResponderHelper
  sudo dscacheutil -flushcache
}

m () {
  node "$DOTFILES/bin/mail.js" "$1"
}

ctx () {
   echo "🐳 $(docker context show)"
   echo "⬢ version is $(node --version)"
}
