#!/bin/bash

# Specify the directory where history files are located
history_dir="$HOME/.bash-history-archive"

# Loop through each history file in the directory
for history_file in "$history_dir"/.bash_*; do
    if [ -f "$history_file" ]; then
        # Deduplicate the current history file
        awk '!seen[$0]++' "$history_file" > "${history_file}.tmp" && mv "${history_file}.tmp" "$history_file"
    fi
done
