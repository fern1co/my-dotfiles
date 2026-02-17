#!/bin/bash
source "$HOME/.config/sketchybar/colors.sh"

# Obtener directorio del front app
APP_PATH=$(yabai -m query --windows --window 2>/dev/null |
  jq -r '.["app"]' 2>/dev/null)

# Detectar git repo desde CWD o directorios comunes
GIT_DIR=$(git -C "$HOME" rev-parse --show-toplevel 2>/dev/null)

if [ -z "$GIT_DIR" ]; then
  sketchybar --set $NAME drawing=off
  exit 0
fi

BRANCH=$(git -C "$GIT_DIR" branch --show-current 2>/dev/null)
STATS=$(git -C "$GIT_DIR" diff --shortstat 2>/dev/null)

INSERTIONS=$(echo "$STATS" | grep -o "[0-9]* insertion" | awk '{print $1}')
DELETIONS=$(echo "$STATS" | grep -o "[0-9]* deletion" | awk '{print $1}')

INSERTIONS=${INSERTIONS:-0}
DELETIONS=${DELETIONS:-0}

LABEL="$BRANCH"
[ "$INSERTIONS" -gt 0 ] && LABEL="$LABEL +$INSERTIONS"
[ "$DELETIONS" -gt 0 ] && LABEL="$LABEL -$DELETIONS"

sketchybar --set $NAME \
  drawing=on \
  label="$LABEL"
