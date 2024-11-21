#!/bin/bash

echo "Do you want to:"
echo "1. Dump GNOME settings"
echo "2. Restore GNOME settings"
echo "Enter your choice (1/2):"
read choice

BACKUP_FILE="gnome_settings_backup.txt"

case $choice in
    1)
        echo "Dumping GNOME settings to $BACKUP_FILE..."
        dconf dump / > $BACKUP_FILE
        echo "Done!"
        ;;
    2)
        if [[ -f $BACKUP_FILE ]]; then
            echo "Restoring GNOME settings from $BACKUP_FILE..."
            dconf load / < $BACKUP_FILE
            echo "Done!"
        else
            echo "Backup file $BACKUP_FILE not found!"
        fi
        ;;
    *)
        echo "Invalid choice!"
        ;;
esac

