#!/bin/bash
TIME=$(date '+%H:%M:%S')
DATE=$(date '+%a %d %b' | tr '[:lower:]' '[:upper:]')
sketchybar --set $NAME label="$TIME - $DATE" \
  label.font="JetBrains Mono:Bold:13.0"
