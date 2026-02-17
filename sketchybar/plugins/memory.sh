#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"

# Memory usada en GB
MEM=$(memory_pressure | grep "System-wide memory free percentage" |
  awk '{print 100 - $NF}' | cut -d. -f1)

TOTAL=$(sysctl -n hw.memsize | awk '{printf "%.0f", $1/1073741824}')
USED=$(echo "$MEM $TOTAL" | awk '{printf "%.1f", $1*$2/100}')

if [ "$(echo "$USED > $TOTAL * 0.85" | bc)" = "1" ]; then
  COLOR=$RED
elif [ "$(echo "$USED > $TOTAL * 0.70" | bc)" = "1" ]; then
  COLOR=$YELLOW
else
  COLOR=$PURPLE
fi

sketchybar --set $NAME \
  label="${USED}GB" \
  label.font="$FONT:Semibold:16.0" \
  icon.padding_right=5 \
  icon.color=$COLOR \
  label.color=$COLOR
