#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"

CPU=$(top -l 1 | grep "CPU usage" | awk '{print int($3)}')

# Color dinámico según carga
if [ "$CPU" -gt 80 ]; then
  COLOR=$RED
elif [ "$CPU" -gt 50 ]; then
  COLOR=$YELLOW
else
  COLOR=$ACCENT
fi

sketchybar --set $NAME \
  label="${CPU}%" \
  icon="󰻠 " \
  icon.padding_right=5 \
  icon.color=$COLOR \
  label.font="$FONT:Semibold:16.0" \
  label.color=$COLOR
