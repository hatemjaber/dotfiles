#!/bin/bash

# Fetch the latest Docker Compose version
LATEST_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | cut -d '"' -f 4)

# Download the latest Docker Compose binary for Linux
curl -L "https://github.com/docker/compose/releases/download/${LATEST_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose

# Make the binary executable
chmod +x /usr/local/bin/docker-compose

# Display the installed version
docker-compose --version

