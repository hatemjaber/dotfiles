#!/bin/bash

# Initial update, upgrade, and clean
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean -y
sudo apt clean -y

# Download and Install Google Chrome and VS Code
TEMP_DIR=$(mktemp -d)
wget -P $TEMP_DIR https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
wget -P $TEMP_DIR https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 -O $TEMP_DIR/vscode.deb

# Install the downloaded packages
sudo dpkg -i $TEMP_DIR/*.deb
sudo apt-get install -f  # This will install any missing dependencies after dpkg

# Flatpak Restore
if [ -f flatpak-packages.list ]; then
    cat flatpak-packages.list | xargs -I {} flatpak install -y {}
else
    echo "Flatpak backup list (flatpak-packages.list) not found!"
fi

# Cleanup and update again
rm -r $TEMP_DIR
sudo apt update
sudo apt upgrade -y
sudo apt autoremove -y
sudo apt autoclean -y
sudo apt clean -y

echo "Restoration and updates completed!"

