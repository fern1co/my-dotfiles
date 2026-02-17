#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"

VOL=$(osascript -e "output volume of (get volume settings)")
MUTED=$(osascript -e "output muted of (get volume settings)")

if [ "$MUTED" = "true" ]; then
  sketchybar --set $NAME label="󰝟 muted" label.color=$SUBTLE
else
  sketchybar --set $NAME label="󰕾 ${VOL}%" label.color=$CYAN icon.font="Hack Nerd Font:Bold:22.0"
fi
