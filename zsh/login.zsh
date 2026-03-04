#!/bin/zsh

# Compile zcompdump in background for faster completion loading
{
  zcompdump="${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump}"
  if [[ -s "$zcompdump" && (! -s "${zcompdump}.zwc" || "$zcompdump" -nt "${zcompdump}.zwc") ]]; then
    zcompile "$zcompdump"
  fi
} &!
