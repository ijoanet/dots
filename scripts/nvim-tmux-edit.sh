#!/bin/bash

# Script to open files in existing nvim window or create new one
# Usage: nvim-tmux-edit [+line] filename

# Function to log to console
log() {
    echo "[$(date '+%H:%M:%S')] $*" >&2
}

log "=== nvim-tmux-edit started ==="
log "Args: $*"
log "PWD: $(pwd)"
log "TMUX: ${TMUX:+active}"

filename=""
line_number=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        +*)
            line_number="${1:1}"  # Remove the + prefix
            log "Line number: $line_number"
            shift
            ;;
        --)
            shift
            filename="$1"
            log "Filename (after --): $filename"
            break
            ;;
        *)
            if [[ -z "$filename" ]]; then
                filename="$1"
                log "Filename: $filename"
            else
                log "Additional arg: $1"
            fi
            shift
            ;;
    esac
done

# If no filename was provided, try to get it from git
if [[ -z "$filename" ]]; then
    log "WARNING: No filename provided in arguments"
    log "This might indicate a lazygit configuration issue"
    exit 1
fi

# Make filename absolute path
if [ -n "$filename" ]; then
    original_filename="$filename"
    filename=$(realpath "$filename" 2>/dev/null || echo "$filename")
    log "Path: '$original_filename' -> '$filename'"
else
    log "ERROR: No filename provided"
    log "This indicates a lazygit configuration issue"
    log "Expected: edit command should pass {{filename}} template"
    exit 1
fi

# Check if we're in a tmux session
if [ -z "$TMUX" ]; then
    log "Not in tmux, using regular nvim"
    # Not in tmux, just use regular nvim
    if [ -n "$line_number" ]; then
        log "Exec: nvim +$line_number '$filename'"
        nvim "+$line_number" "$filename"
    else
        log "Exec: nvim '$filename'"
        nvim "$filename"
    fi
    exit 0
fi

# Check if there's a window with nvim running
log "Searching for nvim windows..."
nvim_windows=$(tmux list-windows -F "#{window_index}:#{window_name}:#{pane_current_command}" | grep nvim)
log "Found: $nvim_windows"

nvim_window=$(echo "$nvim_windows" | head -1 | cut -d: -f1)

if [ -n "$nvim_window" ]; then
    log "Using window: $nvim_window"

    # Switch to the nvim window
    tmux select-window -t "$nvim_window"
    log "Switched to window $nvim_window"

    # Clear any pending command mode and get to normal mode
    tmux send-keys -t "$nvim_window" 'Escape'
    sleep 0.1
    log "Cleared command mode"

    # Send the command with proper escaping
    if [ -n "$line_number" ]; then
        cmd=$(printf ":edit +%s %s" "$line_number" "$filename")
        log "Sending: $cmd"
        tmux send-keys -t "$nvim_window" "$cmd" 'C-m'
    else
        cmd=$(printf ":edit %s" "$filename")
        log "Sending: $cmd"
        tmux send-keys -t "$nvim_window" "$cmd" 'C-m'
    fi

    log "Command sent"
else
    log "No nvim window found, creating new one"
    # No nvim window found, create a new one
    if [ -n "$line_number" ]; then
        new_cmd="nvim \"+$line_number\" \"$filename\""
        log "Creating: $new_cmd"
        tmux new-window -n nvim "zsh"
        tmux send-keys -t nvim "$new_cmd" Enter
    else
        new_cmd="nvim \"$filename\""
        log "Creating: $new_cmd"
        tmux new-window -n nvim "zsh"
        tmux send-keys -t nvim "$new_cmd" Enter
    fi
fi

log "=== nvim-tmux-edit completed ==="
