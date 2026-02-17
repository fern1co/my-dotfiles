#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"

sketchybar --set separator.left \
  icon.color=$BORDER

sketchybar --set front_app \
  label="| $INFO" \
  label.color=0xffc8cdd4 \
  label.font="JetBrains Mono:Medium:11.0"
