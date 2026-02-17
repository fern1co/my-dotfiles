#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"

SPACE_IDX=$1
ACCENT_COLOR=$2

# Solo actualiza el space específico, no todos los items
if [ "$SELECTED" = "true" ]; then
  sketchybar --set space.$SPACE_IDX \
    label.color=$BRIGHT \
    background.color=$SURFACE \
    background.border_color=$BORDER \
    background.padding_left=8 \
    background.padding_right=8 \
    icon.color=$ACCENT_COLOR
else
  sketchybar --set space.$SPACE_IDX \
    label.color=$SUBTLE \
    background.color=$TRANSPARENT \
    background.border_color=$TRANSPARENT \
    background.padding_left=6 \
    background.padding_right=6 \
    icon.color=$MUTED
fi
