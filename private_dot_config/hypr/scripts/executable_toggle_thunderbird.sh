#!/bin/bash

# Check if thunderbird is already running with the scratchpad class
if pgrep -f "thunderbird.*--class scratchpad" > /dev/null; then
    # If running, just toggle the workspace
    hyprctl dispatch togglespecialworkspace thunderbird
else
    # If not running, launch it into the special workspace
    hyprctl dispatch exec "[workspace special:thunderbird] thunderbird --class scratchpad --title thunderbird"
fi
