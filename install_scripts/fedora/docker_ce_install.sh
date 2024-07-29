#!/bin/bash
set -e

# Update and upgrade system
dnf update -y
dnf upgrade -y

# Confirm removal of Docker components
read -p "Do you want to remove existing Docker components? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    dnf remove docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-selinux docker-engine-selinux docker-engine -y
fi

# Install required packages
dnf install -y dnf-plugins-core

# Add Docker repository
dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo

# Install Docker components
dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add the user to the docker group (creating the group if it doesn't exist)
if [ ! $(getent group docker) ]; then
    groupadd docker
fi
usermod -aG docker $USER

echo "Installation completed! Please log out and back in for the changes to take effect."
