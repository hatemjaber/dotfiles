#!/bin/bash
set -e

# Remove Docker components
apt remove docker docker-ce docker-ce-cli containerd.io -y

# Remove Docker GPG key and repository
rm -f /etc/apt/sources.list.d/docker.list
rm -f /etc/apt/keyrings/docker.gpg

# Remove Docker Compose binary
rm -f /usr/local/bin/docker-compose

# Remove the user from the docker group
gpasswd -d $USER docker

echo "Docker and Docker Compose removal completed!"

