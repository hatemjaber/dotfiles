#!/bin/bash

# Set the starting directory (current directory by default)
START_DIR="${1:-.}"

# Find all directories recursively
find "$START_DIR" -type d | while read -r dir; do
    # Get the base name of the directory
    base_name=$(basename "$dir")
    
    # Look for a file with "._" prefix in the parent directory
    parent_dir=$(dirname "$dir")
    dot_file="$parent_dir/._$base_name"
    
    # Check if the file exists and remove it
    if [ -f "$dot_file" ]; then
        echo "Found match: $dot_file"
        # Uncomment the line below to actually remove the files
        rm "$dot_file"
    fi
done