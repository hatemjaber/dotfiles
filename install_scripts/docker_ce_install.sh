#!/bin/bash
set -e

# Update and upgrade system
apt update
apt upgrade -y

# Confirm removal of Docker components
read -p "Do you want to remove existing Docker components? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    apt remove docker docker-engine docker.io containerd runc -y
fi

# Install required packages
apt install ca-certificates curl gnupg lsb-release -y

# Add Docker GPG key and repository if they don't exist
if [ ! -f /etc/apt/keyrings/docker.gpg ]; then
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt update
fi

# Install Docker components
apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# Add the user to the docker group (creating the group if it doesn't exist)
if [ ! $(getent group docker) ]; then
    groupadd docker
fi
usermod -aG docker $USER

echo "Installation completed!"