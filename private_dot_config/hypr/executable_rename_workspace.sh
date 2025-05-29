#!/bin/bash

# Get the currently active workspace ID
WORKSPACE_ID=$(hyprctl activeworkspace -j | jq -r ".id")

# Get the current workspace name
CURRENT_NAME=$(hyprctl activeworkspace -j | jq -r ".name")

# Prompt for a new name using wofi (or replace with zenity if preferred)
NEW_NAME=$(echo "$CURRENT_NAME" | rofi -dmenu -p "Rename Workspace")

echo "workspace id: $WORKSPACE_ID"
echo "Renaming workspace $CURRENT_NAME to $NEW_NAME"
# Ensure the new name is not empty before renaming
if [[ -n "$NEW_NAME" ]]; then
    echo "Running: hyprctl dispatch renameworkspace $WORKSPACE_ID $NEW_NAME"
    hyprctl dispatch renameworkspace $WORKSPACE_ID "$WORKSPACE_ID: $NEW_NAME"
else
    echo "clearing workspace name"
    hyprctl dispatch renameworkspace $WORKSPACE_ID $WORKSPACE_ID
fi
