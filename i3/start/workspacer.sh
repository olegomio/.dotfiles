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
    local selected_folder=""
    while true; do
        # Create a temporary file for the directory listing
        local tmp_file=$(mktemp)
        echo "CREATE_NEW_PROJECT" > "$tmp_file"
        sleep 0.5
        find "$current_dir" -mindepth 1 -maxdepth 1 -type d >> "$tmp_file"
        
        # Use fzf to select from the combined list
        local selected_folder=$(cat "$tmp_file" | fzf --prompt="Select a directory (or create new): " \
            --preview "if [ {} = 'CREATE_NEW_PROJECT' ]; then echo 'Select this to create a new project'; else tree -C {} | head -20; fi")
        
        # Clean up temporary file
        rm "$tmp_file"

        # Handle the create new project option
        if [ "$selected_folder" = "CREATE_NEW_PROJECT" ]; then
            vared -p "Enter name for new project: " -c new_project_name
            if [ -n "$new_project_name" ]; then
                local new_project_path="$current_dir/$new_project_name"
                if mkdir -p "$new_project_path"; then
                    selected_folder="$new_project_path"
                    printf "%s" "$new_project_path"  # Use printf instead of echo
                    return 0
                fi
            fi
        fi
        # If no directory is selected, break out of the loop
        if [ -z "$selected_folder" ]; then
            echo "No directory selected."
            break
        fi

        # Ask if the user wants to go into the selected directory or stop here
        vared -p "Enter subfolder of $selected_folder (y/n): " -c confirm
        # Clear `confirm` input to avoid it carrying over in the next loop
        if [ "$confirm" = "y" ]; then
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
    if [ -n "$start_dir" ]; then
        workspacer
    else
        echo "No directory selected or created. Exiting."
        exit 1
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
if [ -f "$WORKSPACE_CACHE" ]; then
    echo "Last workspace: $(cat "$WORKSPACE_CACHE")"
    vared -p "Open last workspace? (y/n) " -c cached
    if [ "$cached" = "y" ]; then
        start_dir=$(cat "$WORKSPACE_CACHE")
        workspacer
    else
        project_finder
    fi
else
    project_finder
fi
