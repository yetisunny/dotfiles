#!/bin/bash

# Check if Kitty is already running with the scratchpad class
if pgrep -f "kitty.*--class scratchpad" > /dev/null; then
    # If running, just toggle the workspace
    hyprctl dispatch togglespecialworkspace scratchpad
else
    # If not running, launch it into the special workspace
    hyprctl dispatch exec "[workspace special:scratchpad] kitty --class scratchpad --title scratchpad bash -c 'cd ~/scratchpadNotes && nvim --cmd \"set noswapfile\" mainPad.txt'"
fi
