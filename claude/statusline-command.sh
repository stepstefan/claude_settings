#!/bin/bash
# Agnoster-inspired status line for Claude Code

# Read JSON input
input=$(cat)

# Extract values
dir=$(echo "$input" | jq -r '.workspace.current_dir')
model=$(echo "$input" | jq -r '.model.display_name // empty')

# Abbreviate home directory
abbrev_dir="${dir/#$HOME/\~}"

# Change to directory for git operations
cd "$dir" 2>/dev/null

# Initialize output
output=""

# User@hostname (dimmed, like agnoster context)
output+="$(printf '\033[2m%s@%s\033[0m' "$(whoami)" "$(hostname -s)")"

# Current directory (blue, like agnoster)
output+=" $(printf '\033[34m%s\033[0m' "$abbrev_dir")"

# Git status (mimicking agnoster's git segment)
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    # Get branch name
    branch=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)

    # Check for staged/unstaged changes
    staged=""
    unstaged=""

    # Check if there are staged changes
    if ! git diff --cached --quiet 2>/dev/null; then
        staged="✚"
    fi

    # Check if there are unstaged changes
    if ! git diff --quiet 2>/dev/null; then
        unstaged="±"
    fi

    # Choose color based on dirty status
    if [ -n "$staged" ] || [ -n "$unstaged" ]; then
        # Yellow for dirty (like agnoster)
        output+=" $(printf '\033[33m\ue0a0 %s %s%s\033[0m' "$branch" "$unstaged" "$staged")"
    else
        # Green for clean (like agnoster)
        output+=" $(printf '\033[32m\ue0a0 %s\033[0m' "$branch")"
    fi
fi

# Add model info if available (subtle, at the end)
if [ -n "$model" ]; then
    output+=" $(printf '\033[2m[%s]\033[0m' "$model")"
fi

echo "$output"