#!/bin/zsh

export PATH="/usr/local/sbin:$PATH"
export ITERM_ENABLE_SHELL_INTEGRATION_WITH_TMUX=YES

source ~/.aliases;

autoload -U promptinit; promptinit
prompt pure

source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
