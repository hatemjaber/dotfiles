#!/bin/bash

echo "Removing all traces of Cursor AI..."

# Paths used during installation
APPIMAGE_PATH="$HOME/.local/bin/cursor.appimage"
WRAPPER_PATH="$HOME/.local/bin/cursor"
ICON_PATH="$HOME/.local/share/icons/cursor.png"
DESKTOP_ENTRY_PATH="$HOME/.local/share/applications/cursor.desktop"

# Remove AppImage
if [ -f "$APPIMAGE_PATH" ]; then
    echo "Removing AppImage..."
    rm -f "$APPIMAGE_PATH"
else
    echo "AppImage not found. Skipping."
fi

# Remove wrapper script
if [ -f "$WRAPPER_PATH" ]; then
    echo "Removing wrapper script..."
    rm -f "$WRAPPER_PATH"
else
    echo "Wrapper script not found. Skipping."
fi

# Remove icon
if [ -f "$ICON_PATH" ]; then
    echo "Removing icon..."
    rm -f "$ICON_PATH"
else
    echo "Icon not found. Skipping."
fi

# Remove .desktop entry
if [ -f "$DESKTOP_ENTRY_PATH" ]; then
    echo "Removing .desktop entry..."
    rm -f "$DESKTOP_ENTRY_PATH"
else
    echo ".desktop entry not found. Skipping."
fi

# Update desktop database
echo "Updating desktop database..."
update-desktop-database "$(dirname "$DESKTOP_ENTRY_PATH")"

# Remove user configuration and cache directories (if any)
rm -rf ~/.config/Cursor ~/.config/cursor
rm -rf ~/.local/share/Cursor ~/.local/share/cursor
rm -rf ~/.cache/Cursor ~/.cache/cursor

echo "Cursor AI has been completely removed."

