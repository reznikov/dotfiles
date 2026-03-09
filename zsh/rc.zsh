#!/bin/zsh

# zmodload zsh/zprof

#==============================================================================
# ENVIRONMENT VARIABLES (see also ~/.zshenv)
#==============================================================================

export HISTFILE="$XDG_STATE_HOME/zsh_history"
export HISTSIZE=80000
export SAVEHIST=80000

typeset -U path # deduplicate PATH entries

#==============================================================================
# APPEARANCE (light/dark mode detection)
#==============================================================================

_get-system-appearance() {
  if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == "Dark" ]]; then
    echo dark
  else
    echo light
  fi
}

_update-bat-theme() {
  if [[ "$1" == "dark" ]]; then
    export BAT_THEME="Catppuccin Mocha"
  else
    export BAT_THEME="Catppuccin Latte"
  fi
}

_update-claude-theme() {
  command -v jq &>/dev/null || return
  local claude_config="$HOME/.claude.json"
  [[ -f "$claude_config" ]] || return
  local tmp

  if [[ "$1" == "dark" ]]; then
    # Dark = remove theme key (null = dark)
    tmp=$(mktemp) && jq 'del(.theme)' "$claude_config" > "$tmp" && mv "$tmp" "$claude_config"
  else
    # Light = set theme key
    tmp=$(mktemp) && jq '.theme = "light"' "$claude_config" > "$tmp" && mv "$tmp" "$claude_config"
  fi
}

update-appearance() {
  local mode=$(_get-system-appearance)

  # Skip if appearance hasn't changed
  [[ "$_APPEARANCE" == "$mode" ]] && return
  _APPEARANCE="$mode"

  _update-bat-theme "$mode"
  _update-claude-theme "$mode"
}
# Defer initial appearance check to first prompt (not blocking startup)
autoload -Uz add-zsh-hook
add-zsh-hook precmd update-appearance


#==============================================================================
# SHELL OPTIONS
#==============================================================================

# Navigation
setopt auto_cd # automatically change directory when dir name is typed
setopt extendedglob # enable extended globbing

# Completion
setopt complete_aliases # enable completion for aliases
setopt complete_in_word # enable completion in the middle of a word
setopt no_listambiguous # don't list ambiguous completions

# History
setopt append_history # append to the history file, don't overwrite it
setopt hist_verify # allow editing a command before execution when recalled from history
setopt hist_expire_dups_first # expire duplicate entries first
setopt hist_fcntl_lock # lock the history file with fcntl()
setopt hist_ignore_all_dups # don't record all duplicates
setopt hist_ignore_space # commands starting with space are not recorded
setopt hist_lex_words # treat words as a lexical unit
setopt hist_reduce_blanks # remove repeated blank entries
setopt hist_save_no_dups # don't record all duplicates
setopt inc_append_history # append to the history file immediately
# setopt share_history # share history between sessions

# General
setopt no_flow_control # free up Ctrl+S and Ctrl+Q
setopt interactive_comments # allow comments in interactive shell
setopt no_beep # disable terminal bell

#==============================================================================
# DIRECTORY NAVIGATION
#==============================================================================

if command -v zoxide &>/dev/null; then
  _zoxide_cache="$XDG_CACHE_HOME/zoxide-init.zsh"
  
  if [[ ! -f "$_zoxide_cache" || "$_zoxide_cache" -ot "$(command -v zoxide)" ]]; then
    zoxide init zsh > "$_zoxide_cache"
  fi
  source "$_zoxide_cache"
fi

#==============================================================================
# HOMEBREW CONFIGURATION
#==============================================================================

if [[ -f /opt/homebrew/bin/brew ]]; then
  export BREW_PREFIX="/opt/homebrew"
elif [[ -f /usr/local/bin/brew ]]; then
  export BREW_PREFIX="/usr/local"
fi

if [[ -n "$BREW_PREFIX" ]]; then
  _brew_cache="$XDG_CACHE_HOME/brew-shellenv.zsh"
  if [[ ! -f "$_brew_cache" || "$_brew_cache" -ot "$BREW_PREFIX/bin/brew" ]]; then
    "$BREW_PREFIX/bin/brew" shellenv > "$_brew_cache"
  fi
  source "$_brew_cache"
fi

if [[ -z "$BREW_PREFIX" ]]; then
  print -P "%F{yellow}warning:%f Homebrew not found. Install: https://brew.sh%f" >&2
else
  FPATH="$BREW_PREFIX/share/zsh/site-functions:${FPATH}" # add brew's zsh functions
fi

#==============================================================================
# COMPLETION SYSTEM
#==============================================================================

export ZSH_COMPDUMP="$XDG_CACHE_HOME/zcompdump"

if [[ -n "$BREW_PREFIX" ]]; then
  autoload -Uz compinit

  # Only regenerate compdump once per day
  if [[ -f "$ZSH_COMPDUMP" && $(find "$ZSH_COMPDUMP" -mtime -1 2>/dev/null) ]]; then
    compinit -C -d "$ZSH_COMPDUMP"  # skip security check, use cache
  else
    compinit -d "$ZSH_COMPDUMP"
  fi

  source "$BREW_PREFIX/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh"

  zstyle ':completion:*' menu no
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
  zstyle ':fzf-tab:*' fzf-flags --height=40% --layout=reverse --border
  zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza --tree --level=1 $realpath'
  zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --style=numbers --color=always --line-range :100 $realpath 2>/dev/null || eza --tree --level=1 $realpath 2>/dev/null'

  # History search: ↑/↓ filter by current input
  autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
  zle -N up-line-or-beginning-search
  zle -N down-line-or-beginning-search
  bindkey '^[[A' up-line-or-beginning-search    # ↑
  bindkey '^[OA' up-line-or-beginning-search
  bindkey '^[[B' down-line-or-beginning-search  # ↓
  bindkey '^[OB' down-line-or-beginning-search
fi

#==============================================================================
# PROMPT CONFIGURATION
#==============================================================================

if command -v starship &>/dev/null; then
  _starship_cache="$XDG_CACHE_HOME/starship-init.zsh"
  if [[ ! -f "$_starship_cache" || "$_starship_cache" -ot "$(command -v starship)" ]]; then
    starship init zsh > "$_starship_cache"
  fi

  source "$_starship_cache"
else
  PS1='%F{blue}%/%f # '
fi

#==============================================================================
# FZF/FD CONFIGURATION
#==============================================================================

if command -v fzf &>/dev/null; then
  # Load fzf completions and key bindings
  source "$BREW_PREFIX/opt/fzf/shell/completion.zsh" 2> /dev/null
  source "$BREW_PREFIX/opt/fzf/shell/key-bindings.zsh" 2> /dev/null

  # Set default fzf options
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
  export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
  export FZF_ALT_C_OPTS="--preview 'eza --tree --level=1 {}'"

  if command -v rg &>/dev/null; then
      export FZF_DEFAULT_COMMAND='rg --files --hidden'
  fi

  if command -v fd &>/dev/null; then
      export FZF_CTRL_T_COMMAND='fd --type f --hidden'
      export FZF_ALT_C_COMMAND='fd --type d --hidden'
  fi
fi

#==============================================================================
# ALIASES
#==============================================================================

# File listing (eza)
alias ls="eza"
alias ll="eza -lh --git"
alias la="eza -lah --git"
alias lt="eza --tree --level=2"

# Modern replacements
alias cat="bat --paging=never"

# Shorthand
alias d="docker"
alias g="git"

# Suffix aliases — open by extension
alias -s {json,js,ts,html}="$EDITOR"

# Sandboxed commands
safe()   { safehouse "$@"; }
# claude() { safe claude --dangerously-skip-permissions "$@"; }

#==============================================================================
# AUTOLOADED FUNCTIONS
#==============================================================================

autoload -Uz dot

#==============================================================================
# LOCAL CUSTOMIZATIONS
#==============================================================================

# Source local customizations if they exist
if [[ -f "$DOTFILES_LOCAL/zsh/rc.zsh" ]]; then
  source "$DOTFILES_LOCAL/zsh/rc.zsh"
fi
