#!/bin/bash

uninstallCursor() {
    # Paths used during installation
    APPIMAGE_PATH="$HOME/.local/bin/cursor.appimage"
    ICON_PATH="$HOME/.local/share/icons/cursor.png"
    DESKTOP_ENTRY_PATH="$HOME/.local/share/applications/cursor.desktop"

    echo "Uninstalling Cursor AI IDE..."

    # Remove AppImage
    if [ -f "$APPIMAGE_PATH" ]; then
        echo "Removing AppImage..."
        rm -f "$APPIMAGE_PATH"
    else
        echo "AppImage not found. Skipping."
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

    echo "Cursor AI IDE has been uninstalled."
}

uninstallCursor

