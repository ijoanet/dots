#!/bin/bash
cd "$1" 2>/dev/null || exit 1

SCRIPT_DIR="$(dirname "$0")"

# Get outputs from individual scripts
push=$("$SCRIPT_DIR/git-push-count.sh" "$1")
pull=$("$SCRIPT_DIR/git-pull-count.sh" "$1")

# Combine outputs
output="${push}${pull}"

if [ -n "$output" ]; then
    echo "$output "
fi
