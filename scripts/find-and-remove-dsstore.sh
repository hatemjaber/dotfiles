#!/bin/bash

# Set the starting directory (current directory by default)
START_DIR="${1:-.}"

# Find and remove .DS_Store and ._DS_Store files
find "$START_DIR" -type f \( -name ".DS_Store" -o -name "._DS_Store" \) -print -delete

echo "Completed: All .DS_Store and ._DS_Store files have been found and removed."