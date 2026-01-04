#!/bin/bash

BAT_PATH="/sys/class/power_supply/BAT0/capacity"
if [ ! -f "$BAT_PATH" ]; then
    BAT_PATH="/sys/class/power_supply/BAT1/capacity"
fi

PERCENT=$(cat "$BAT_PATH")
NEW_LABEL=" ${PERCENT}%"

CONFIG_PATH="$HOME/.config/swaync/config.json"
TEMP_FILE=$(mktemp)

jq --arg lbl "$NEW_LABEL" \
'.["widget-config"]["menubar#top"]["menu#powermode-buttons"].label = $lbl' \
"$CONFIG_PATH" > "$TEMP_FILE" && mv "$TEMP_FILE" "$CONFIG_PATH"

swaync-client -R
swaync-client -t -s -sw