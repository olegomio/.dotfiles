#!/bin/zsh
set -euo pipefail

# --- Setup Logging ---
LOG_DIR="logs"
LOG_FILE="$LOG_DIR/dependencies.log"

# Create log directory if it doesn't exist
if [ ! -d "$LOG_DIR" ]; then
  mkdir -p "$LOG_DIR"
fi

# Ensure the log file exists
touch "$LOG_FILE"

# Logging function: appends a message with timestamp to the log file.
log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $1" >> "$LOG_FILE"
}

log "=== Starting configuration sync ==="

# --- Helper Functions ---

# Check if a command exists.
command_exists() {
  command -v "$1" &>/dev/null
}

# lnsp: Creates necessary directories, ensures the source file exists,
# and then creates a symbolic link from source_file to symlink.
# If a symlink already exists at the destination:
#   - If it points to the correct source, the function skips creation.
#   - Otherwise, it removes the existing link (or file) before creating the new symlink.
lnsp() {
  if [ "$#" -ne 2 ]; then
    echo "Usage: lnsp <path to source file> <path for symlink>"
    log "ERROR: lnsp was called with wrong number of arguments."
    return 1
  fi

  local source_file="$1"
  local symlink="$2"

  # Create directories for the source file.
  local source_dir
  source_dir=$(dirname "$source_file")
  if ! mkdir -p "$source_dir"; then
    echo "Error: Could not create directory $source_dir"
    log "ERROR: Failed to create source directory $source_dir"
    return 1
  fi

  # If the source file doesn't exist, create it.
  if [ ! -e "$source_file" ]; then
    if ! touch "$source_file"; then
      echo "Error: Could not create file $source_file"
      log "ERROR: Failed to create source file $source_file"
      return 1
    fi
    log "INFO: Created missing source file: $source_file"
  fi

  # Create directories for the symlink.
  local link_dir
  link_dir=$(dirname "$symlink")
  if ! mkdir -p "$link_dir"; then
    echo "Error: Could not create target directory $link_dir"
    log "ERROR: Failed to create target directory $link_dir"
    return 1
  fi

  # Check if the destination already exists.
  if [ -L "$symlink" ]; then
    local current_target
    current_target=$(readlink "$symlink")
    if [ "$current_target" = "$source_file" ]; then
      echo "Symlink $symlink already exists and is correct."
      log "INFO: Symlink $symlink already exists and points to $source_file. Skipping."
      return 0
    else
      echo "Symlink $symlink exists but points to $current_target. Replacing it."
      log "WARNING: Symlink $symlink exists and points to $current_target. Replacing with correct link to $source_file."
      rm "$symlink"
    fi
  elif [ -e "$symlink" ]; then
    # If a regular file exists (should have been backed up already), then remove it.
    echo "File $symlink exists but is not a symlink. Removing it."
    log "WARNING: File $symlink exists and is not a symlink. Removing it."
    rm "$symlink"
  fi

  # Create the symbolic link.
  if ! ln -s "$source_file" "$symlink"; then
    echo "Error: Could not create symbolic link from $symlink to $source_file"
    log "ERROR: Failed to create symlink: $symlink -> $source_file"
    return 1
  fi

  echo "Symbolic link created: $symlink -> $source_file"
  log "SUCCESS: Created symbolic link: $symlink -> $source_file"
}

# backup_file: If a regular file (not a symlink) exists, create a backup.
# If a backup already exists, append a consecutive number (e.g. .d.1, .d.2, etc.)
backup_file() {
  local file="$1"
  if [ -e "$file" ] && [ ! -L "$file" ]; then
    local backup="${file}.d"
    local counter=1
    while [ -e "$backup" ]; do
      backup="${file}.d.$counter"
      (( counter++ ))
    done
    echo "Backing up $file to $backup"
    log "INFO: Backing up $file to $backup"
    cp "$file" "$backup"
  fi
}

# backup_and_merge: Creates a backup, copies the repo file to the destination,
# and appends the content of the merge file. The backup remains unchanged.
backup_and_merge() {
  local dest="$1"
  local repo_file="$2"
  local merge_file="$3"

  backup_file "$dest"

  local dest_dir
  dest_dir=$(dirname "$dest")
  if [ ! -d "$dest_dir" ]; then
    echo "Creating target directory: $dest_dir"
    log "INFO: Creating target directory $dest_dir"
    mkdir -p "$dest_dir"
  fi

  local repo_abs
  repo_abs="$(pwd)/$repo_file"
  local merge_abs
  merge_abs="$(pwd)/$merge_file"

  if [ ! -f "$repo_abs" ]; then
    echo "Error: Repo file $repo_abs does not exist."
    log "ERROR: Repo file $repo_abs not found."
    return 1
  fi

  if [ ! -f "$merge_abs" ]; then
    echo "Error: Merge file $merge_abs does not exist."
    log "ERROR: Merge file $merge_abs not found."
    return 1
  fi

  echo "Creating merged file: copying $repo_abs to $dest and appending $merge_abs"
  log "INFO: Creating merged file. Copying $repo_abs to $dest and appending $merge_abs"
  cp "$repo_abs" "$dest"
  cat "$merge_abs" >> "$dest"
  echo "Merge complete: $dest created (backup remains unchanged)."
  log "SUCCESS: Merged file created at $dest"
}

# --- Dependencies List ---
# Format: id:destination_path:repo_file:[merge_file (optional)]
#
# id:         Identifier (also used for checking if the tool is installed)
# destination: Where the final config file should be (can include ~)
# repo_file:  Relative path in the repo for the source file.
# merge_file: Optional relative path for additional content to merge.
dependencies=(
    "i3:~/.config/i3/config:i3/config"
    "nvim:~/.config/nvim/init.lua:nvim/init.lua"
    "tmux:~/.tmux.conf:tmux/.tmux.conf"
    "zsh:~/.zshrc:zsh/.zshrc"
    # For zsh aliases: may optionally merge additional settings.
    "zsh_alias:~/.oh-my-zsh/custom/aliases.zsh:.oh-my-zsh/custom/aliases.zsh:.oh-my-zsh/custom/aliases.zsh"
)

# --- Main Processing Loop ---
for dep in "${dependencies[@]}"; do
  IFS=':' read -r id dest repo_file merge_file <<< "$dep"
  echo "-----------------------------------------------------"
  echo "Processing dependency: $id"
  log "INFO: Processing dependency: $id"

  # For dependencies other than 'zsh_alias', check if the tool is installed.
  if [ "$id" != "zsh_alias" ]; then
    if ! command_exists "$id"; then
      echo "Warning: Tool '$id' is not installed. Skipping configuration."
      log "WARNING: Tool '$id' is not installed. Skipping configuration."
      continue
    fi
  fi

  # Replace ~ with $HOME
  dest="${dest/#\~/$HOME}"

  if [ -z "${merge_file:-}" ]; then
    # No merge file: create backup and create symlink.
    backup_file "$dest"
    lnsp "$(pwd)/$repo_file" "$dest"
  else
    # Merge file exists - ask the user if they want to create a merged file.
    echo "Merge file exists for '$id': $(pwd)/$merge_file"
    echo "Do you want to merge the contents of the merge file into the final configuration (instead of creating a symlink)? (y/n)"
    log "INFO: Merge file found for '$id': $(pwd)/$merge_file. Asking user for merge."
    read -r answer
    if [[ "$answer" =~ ^[Yy] ]]; then
      backup_and_merge "$dest" "$repo_file" "$merge_file"
    else
      backup_file "$dest"
      lnsp "$(pwd)/$repo_file" "$dest"
    fi
  fi
done

echo "-----------------------------------------------------"
echo "Configuration sync complete."
log "=== Configuration sync complete ==="

