#!/bin/zsh
# Define the projects directory path
project_dir="$HOME/repos"
# Check if fzf is installed
if ! type "fzf" &> /dev/null; then
  echo "fzf is required for this script. Install it with 'brew install fzf' or 'sudo apt install fzf'."
  exit 1
fi
# File for cached workspace
WORKSPACE_CACHE="$HOME/.config/i3/start/.workspace_cache"
# Function to navigate directories
navigate_directory() {
    local current_dir="$1"
    while true; do
        # Use fzf to select a subdirectory within the current directory
        local selected_folder=$(find "$current_dir" -mindepth 1 -maxdepth 1 -type d | fzf --prompt="Select a directory: " --preview "tree -C {} | head -20")
        # If no directory is selected, break out of the loop
        if [[ -z "$selected_folder" ]]; then
            echo "No directory selected."
            break
        fi
        # Ask if the user wants to go into the selected directory or stop here
        vared -p "Enter subfolder of $selected_folder (y/n): " -c confirm
        # Clear confirm input to avoid it carrying over in the next loop
        if [[ "$confirm" == "y" ]]; then
            # Navigate into the selected directory and continue the loop
            current_dir="$selected_folder"
            confirm=""
        else
            # Exit the navigation loop
            current_dir="$selected_folder"
            break
        fi
    done
    # Return the final directory after navigation
    echo "$current_dir"
}
# Define project_finder function
project_finder() {
    # Set start_dir to the final directory chosen with navigate_directory
    start_dir=$(navigate_directory "$project_dir")
    if [[ -n $start_dir ]]; then
        workspacer
    else
        vared -p "No project selected. Type name of project to create a new one: " -c start_dir
        # Check if the start_dir is empty, if so, set it to the home directory
        if [[ -z "$start_dir" ]]; then
            echo "No directory entered. Starting in home directory."
            start_dir="$HOME"
        else
            mkdir -p "$start_dir"
            echo "Directory created."
        fi
        workspacer
    fi
}
# Define workspacer function
workspacer() {
    # Cache the selected directory
    echo "$start_dir" > "$WORKSPACE_CACHE"
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
    sleep 0.5
    tmux rename-window "laravel"
    tmux send-keys "php artisan serve" Enter
    sleep 0.5
    tmux new-window -c "$start_dir" &
    tmux send-keys "npm run dev" Enter
    sleep 0.5
    tmux rename-window "vue"
    i3-msg focus right
    firefox 
}
# Check if cached workspace directory exists
if [[ -f "$WORKSPACE_CACHE" ]]; then
    echo "Last workspace: $(cat "$WORKSPACE_CACHE")"
    vared -p "Open last workspace? (y/n) " -c cached
    if [[ $cached == "y" ]]; then
        start_dir=$(cat "$WORKSPACE_CACHE")
        workspacer
    else
        project_finder
    fi
else
    project_finder
fi
