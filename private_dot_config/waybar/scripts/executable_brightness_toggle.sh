#!/bin/bash

STATE_FILE="/tmp/brightness_state"

if [[ -f "$STATE_FILE" ]]; then
    STATE=$(cat "$STATE_FILE")
else
    STATE="bright"
fi

if [[ "$STATE" == "bright" ]]; then
    ddcutil setvcp 10 0 --display 1
    ddcutil setvcp 10 0 --display 2
    echo "dim" > "$STATE_FILE"
    echo "☾ Dim"
else
    ddcutil setvcp 10 100 --display 1
    ddcutil setvcp 10 100 --display 2
    echo "bright" > "$STATE_FILE"
    echo "☀ Bright"
fi
