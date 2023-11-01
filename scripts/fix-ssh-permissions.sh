#!/bin/bash

# Fix the ~/.ssh directory permission
chmod 700 ~/.ssh

# Fix private key permissions
chmod 600 ~/.ssh/id_rsa  # replace id_rsa with your private key filename if different

# Fix public key permissions
chmod 644 ~/.ssh/id_rsa.pub  # replace id_rsa.pub with your public key filename if different

# Fix permissions for the known_hosts file
chmod 644 ~/.ssh/known_hosts

# Fix permissions for the authorized_keys file
chmod 600 ~/.ssh/authorized_keys

# Fix permissions for the config file (if you have one)
chmod 644 ~/.ssh/config
