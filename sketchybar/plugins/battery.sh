#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"

PCT=$(pmset -g batt | grep -o "[0-9]*%" | cut -d% -f1)
CHARGING=$(pmset -g batt | grep "AC Power")
FONT="Hack Nerd Font"

if [ -n "$CHARGING" ]; then
  ICON="󰂄"
  COLOR=$GREEN
elif [ "$PCT" -lt 10 ]; then
  ICON="󰁺"
  COLOR=$RED
elif [ "$PCT" -lt 15 ]; then
  ICON="󰁻"
  COLOR=$RED
elif [ "$PCT" -lt 30 ]; then
  ICON="󰁼 "
  COLOR=$YELLOW
elif [ "$PCT" -lt 60 ]; then
  ICON="󰁿"
  COLOR=$YELLOW
else
  ICON="󰂂"
  COLOR=$GREEN
fi

sketchybar --set $NAME \
  label="${ICON} ${PCT}%" \
  label.color=$COLOR \
  icon.font="Hack Nerd Font:Bold:22.0" \
  label.font="$FONT:Semibold:16.0"
