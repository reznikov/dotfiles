#!/bin/zsh

declare -A ssid_to_location=(
  ["w"]="Home"
)

timestamp() {
    date +"[%Y-%m-%d %H:%M] $*"
}

debug() {
  tail -f "$HOME/Library/Logs/wifi-monitor.log"
}

uninstall() {
  cd "$(dirname "$0")/.."

  launchctl unload ~/Library/LaunchAgents/wifi-monitor.plist
  rm ~/Library/LaunchAgents/wifi-monitor.plist
  rm /usr/local/bin/wifi-monitor

  exit 0
}

install() {
  cd "$(dirname "$0")/.."

  ln -s "$PWD/wifi/wifi-monitor.sh" /usr/local/bin/wifi-monitor
  chmod +x /usr/local/bin/wifi-monitor

  cp "$PWD/wifi/wifi-monitor.plist" ~/Library/LaunchAgents/
  launchctl load ~/Library/LaunchAgents/wifi-monitor.plist

  exit 0
}

run() {
  source "$HOME/dotfiles/wifi/.config/locations.sh"

  exec 2>&1 >> "$HOME/Library/Logs/wifi-monitor.log"

  sleep 2

  ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Resources/airport -I | awk -F' SSID: '  '/ SSID: / {print $2}')

  current_location=$(scselect | tail -n +2 | egrep '^\ +\*' | cut -d \( -f 2- | sed 's/)$//')
  next_location=$DEFAULT_LOCATION

  if [[ "$current_location" == "" ]]; then
    timestamp "No network connected"
    exit 0
  fi

  timestamp "Connected to $ssid"

  if [[ -n ${LOCATIONS[${ssid}]} ]]; then
    next_location="${LOCATIONS[${ssid}]}"
  fi

  if [[ "$current_location" == "$next_location" ]]; then
    timestamp "Locations match, skipping"
    exit 0
  fi

  timestamp "Switching location to $next_location"

  scselect $next_location
}

if [[ $1 == "install" ]]; then
  (install)
elif [[ $1 == "uninstall" ]]; then
  (uninstall)
else
  (run)
fi
