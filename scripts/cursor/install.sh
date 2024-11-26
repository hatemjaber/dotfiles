#!/bin/bash

installCursor() {
    # Define URLs and paths
    CURSOR_URL="https://downloader.cursor.sh/linux/appImage/x64"
    APPIMAGE_PATH="$HOME/.local/bin/cursor.appimage"
    WRAPPER_PATH="$HOME/.local/bin/cursor"
    ICON_PATH="$HOME/.local/share/icons/cursor.png"
    DESKTOP_ENTRY_PATH="$HOME/.local/share/applications/cursor.desktop"

    # Create necessary directories
    mkdir -p "$(dirname "$APPIMAGE_PATH")" "$(dirname "$ICON_PATH")" "$(dirname "$DESKTOP_ENTRY_PATH")"

    # Download Cursor AppImage
    echo "Downloading Cursor AppImage..."
    curl -L "$CURSOR_URL" -o "$APPIMAGE_PATH"
    chmod +x "$APPIMAGE_PATH"

    # Extract icon from AppImage
    echo "Extracting icon from AppImage..."
    "$APPIMAGE_PATH" --appimage-extract > /dev/null
    if [ -d "squashfs-root" ]; then
        ICON_SOURCE=$(find squashfs-root -name "*.png" | head -n 1)
        if [ -f "$ICON_SOURCE" ]; then
            cp "$ICON_SOURCE" "$ICON_PATH"
            echo "Icon extracted and copied to $ICON_PATH."
        else
            echo "Icon file not found in extracted AppImage. Skipping icon setup."
        fi
        # Clean up extraction directory
        rm -rf squashfs-root
    else
        echo "Failed to extract AppImage. Icon setup skipped."
    fi

    # Create .desktop entry for Cursor
    echo "Creating .desktop entry for Cursor..."
    cat > "$DESKTOP_ENTRY_PATH" <<EOL
[Desktop Entry]
Name=Cursor AI IDE
Exec=$APPIMAGE_PATH
Icon=$ICON_PATH
Type=Application
Categories=Development;
EOL

    # Create wrapper script in ~/.local/bin
    echo "Creating wrapper script for Cursor..."
    cat > "$WRAPPER_PATH" <<'EOL'
#!/bin/bash
# Wrapper script for Cursor AppImage
CURSOR_APPIMAGE="$HOME/.local/bin/cursor.appimage"

# Default to current directory if no arguments are provided
TARGET_DIR="${1:-.}"

# Launch Cursor in the background and suppress output
"$CURSOR_APPIMAGE" "$TARGET_DIR" > /dev/null 2>&1 & disown
EOL

    chmod +x "$WRAPPER_PATH"

    # Ensure ~/.local/bin is in PATH
    if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
        echo "Adding ~/.local/bin to PATH..."
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
        source "$HOME/.bashrc"
    fi

    # Update desktop database
    echo "Updating desktop database..."
    update-desktop-database "$(dirname "$DESKTOP_ENTRY_PATH")"

    echo "Cursor AI IDE installation complete. You can use the 'cursor' command to open projects."
}

installCursor

