#!/bin/zsh

# Prompt for the directory to start in, with enhanced user input handling
vared -p "Enter the directory to start in: " -c start_dir

# Check if the start_dir is empty, if so, set it to the home directory
if [[ -z "$start_dir" ]]; then
    echo "No directory entered. Starting in home directory."
    start_dir="$HOME"
fi

# Check if the directory exists, and create it if it doesn't
if [[ ! -d $start_dir ]]; then
    echo "Directory does not exist. Do you want to create it? (y/n)"
    read -k1 create_dir
    if [[ $create_dir == "y" ]]; then
        mkdir -p "$start_dir"
        echo "Directory created."
    else
        echo "Starting in home directory."
        start_dir="$HOME"
    fi
fi

# Start i3 terminals with tmux in the specified directory
i3-msg split h
i3-sensible-terminal -e tmux new-session -c "$start_dir" &
sleep 0.5
i3-msg focus left
i3-msg resize shrink width 20 px or 20 ppt
i3-msg split v
i3-sensible-terminal -e tmux new-session -c "$start_dir" &
sleep 0.5

# Focus back on the original terminal
i3-msg focus up
i3-msg resize shrink height 10 px or 10 ppt
tmux send-keys "cd $start_dir" C-m

# Clear the terminal screen in the original terminal
clear

