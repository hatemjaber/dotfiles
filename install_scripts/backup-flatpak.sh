#!/bin/bash

# Flatpak Backup
flatpak list --app --columns=application > flatpak-packages.list

echo "Flatpak backup completed!"

