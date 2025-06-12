
#!/bin/bash

# Check if obsidian window exists on special:obsidian workspace
if hyprctl clients -j | jq -e '.[] | select(.class == "obsidian" and .workspace.name == "special:obsidian")' > /dev/null; then
    # Obsidan window exists, toggle the special workspace
    hyprctl dispatch togglespecialworkspace obsidian
else
    # Obsidian not running, launch it into special workspace
    hyprctl dispatch exec "[workspace special:obsidian] obsidian --class obsidian --title obsidian"
fi

