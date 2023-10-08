#!/bin/bash

# Define paths
SERVICE_DIR="/etc/systemd/system/"
SERVICE_FILE="battery_thresholds.service"
SCRIPT_DIR="/usr/local/bin/"
SCRIPT_FILE="set_battery_thresholds.sh"
CURRENT_DIR="$(dirname "$0")"

# Copy the script to /usr/local/bin/
cp "$CURRENT_DIR/$SCRIPT_FILE" "$SCRIPT_DIR"
chmod +x "$SCRIPT_DIR/$SCRIPT_FILE"

# Copy the service file to /etc/systemd/system/
cp "$CURRENT_DIR/$SERVICE_FILE" "$SERVICE_DIR"

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable "$SERVICE_FILE"
systemctl start "$SERVICE_FILE"

# Print out the status to verify
systemctl status "$SERVICE_FILE"

echo "Setup completed!"

