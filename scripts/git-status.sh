#!/bin/bash
cd "$1" 2>/dev/null || exit 1

# Get git status output
status_output=$(git status --porcelain 2>/dev/null)

if [ -z "$status_output" ]; then
    exit 0
fi

# Count staged additions and untracked files (new files)
staged_added=$(echo "$status_output" | grep -E '^A' | wc -l | tr -d ' ')
untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
total_added=$((staged_added + untracked))

# Count all modifications to tracked files (staged or unstaged)
modified=$(echo "$status_output" | grep -E '^M|^.M' | wc -l | tr -d ' ')

# Count all deletions of tracked files (staged or unstaged)
deleted=$(echo "$status_output" | grep -E '^D|^.D' | wc -l | tr -d ' ')

# Build output
output=""
if [ "$total_added" -gt 0 ]; then
    output="${output}+${total_added}"
fi
if [ "$modified" -gt 0 ]; then
    output="${output}~${modified}"
fi
if [ "$deleted" -gt 0 ]; then
    output="${output}-${deleted}"
fi

if [ -n "$output" ]; then
    echo "$output "
fi
