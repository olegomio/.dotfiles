#!/bin/bash
# Directory of your config file
DIRECTORY=~/.config/i3
PATHFINDER=$DIRECTORY/pathfinder.txt

# Capture the current path in the tmux pane
tmux display-message -p "#{pane_current_path}" > $PATHFINDER

# Read the directory path from the file and remove tmp file
TARGET=$(cat $PATHFINDER)
rm $PATHFINDER 

# Open a new terminal in that directory and start tmux
i3-sensible-terminal -e bash -c "cd \"$TARGET\" && tmux || (echo 'Failed to start tmux in $TARGET'; read)"

