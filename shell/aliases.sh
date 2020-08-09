#!/bin/zsh

alias weather="curl https://wttr.in/riga\?FQ"

alias ll="ls -lhFG"
alias la="ls -lahFG"

alias bubu="brew update && brew upgrade && brew cleanup"

flushdns () {
  sudo killall -HUP mDNSResponder
  sudo killall mDNSResponderHelper
  sudo dscacheutil -flushcache
}
