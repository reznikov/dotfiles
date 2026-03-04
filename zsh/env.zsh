#!/bin/zsh

#==============================================================================
# ENVIRONMENT VARIABLES
# Loaded by ALL zsh invocations (interactive, non-interactive, scripts)
#==============================================================================

export EDITOR="code"
export CLICOLOR=1
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Machine identity (override in dotfiles.local/zsh/env.zsh)
export MACHINE="${MACHINE:-personal}"

# OS detection
export IS_MACOS=false
export IS_LINUX=false
if [[ "$OSTYPE" == darwin* ]]; then
  IS_MACOS=true
  export BROWSER="open"
  export SHELL_SESSIONS_DIR="$XDG_STATE_HOME/zsh_sessions"
elif [[ "$OSTYPE" == linux* ]]; then
  IS_LINUX=true
fi

export DOTFILES="$HOME/dotfiles"
export DOTFILES_LOCAL="$HOME/dotfiles.local"

export HOMEBREW_BREWFILE="$DOTFILES_LOCAL/Brewfile"
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_INSECURE_REDIRECT=1

# XDG compliance for tools that support it
export LESSHISTFILE="$XDG_STATE_HOME/lesshst"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export NPM_CONFIG_CACHE="$XDG_CACHE_HOME/npm"

#==============================================================================
# LOCAL OVERRIDES
#==============================================================================

if [[ -f "$DOTFILES_LOCAL/zsh/env.zsh" ]]; then
  source "$DOTFILES_LOCAL/zsh/env.zsh"
fi
