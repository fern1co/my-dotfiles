#!/bin/bash
# Requiere ifstat o netstat
UP=$(netstat -ib | grep -e "en0" | head -1 | awk '{print $7}')
DOWN=$(netstat -ib | grep -e "en0" | head -1 | awk '{print $10}')

format_bytes() {
  local bytes=$1
  if [ "$bytes" -gt 1048576 ]; then
    echo "$(echo "$bytes" | awk '{printf "%.1fM", $1/1048576}')"
  elif [ "$bytes" -gt 1024 ]; then
    echo "$(echo "$bytes" | awk '{printf "%.0fK", $1/1024}')"
  else
    echo "${bytes}B"
  fi
}

UP_FMT=$(format_bytes $UP)
DOWN_FMT=$(format_bytes $DOWN)

sketchybar --set $NAME label="󰇚 ${UP_FMT}  󰕒 ${DOWN_FMT}" icon.font="Hack Nerd Font:Bold:22.0"
