#!/bin/zsh

#==============================================================================
# LOGIN SHELL CONFIGURATION
#==============================================================================

#==============================================================================
# NODE.JS ENVIRONMENT (FNM)
#==============================================================================

eval "$(fnm env --use-on-cd --version-file-strategy=recursive --log-level=quiet)"

#==============================================================================
# VSCODE INTEGRATION
#==============================================================================

if [[ "$TERM_PROGRAM" == "vscode" ]]; then
  _vscode_shell_integration="$XDG_CACHE_HOME/vscode-shell-integration.zsh"
  if [[ ! -f "$_vscode_shell_integration" ]]; then
    code --locate-shell-integration-path zsh > "$_vscode_shell_integration"
  fi
  source "$_vscode_shell_integration"
fi

#==============================================================================
# PATH CONFIGURATION
#==============================================================================

export PATH="/usr/local/bin:/usr/local/sbin:$PATH" # add local bin to PATH
export PATH="$HOME/.local/bin:$PATH" # add user local bin to PATH
export PATH="$FNM_MULTISHELL_PATH/bin:$PATH" # add fnm managed npm packages to PATH

#==============================================================================
# LOCAL OVERRIDES
#==============================================================================

if [[ -f "$DOTFILES_LOCAL/zsh/profile.zsh" ]]; then
  source "$DOTFILES_LOCAL/zsh/profile.zsh"
fi
