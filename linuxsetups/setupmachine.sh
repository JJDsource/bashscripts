#!/bin/bash

#Run before executing chmod +x setup.sh

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Prompt for username
read -p "Enter username: " username

# Check if username is provided
if [[ -z $username ]]; then
  echo "Username is missing."
  exit 1
fi

# Update and upgrade packages
apt-get update
apt-get upgrade -y

# Install sudo
apt-get install -y sudo

# Add user
useradd -m $username

# Set password for the new user
echo "Enter password for user $username:"
read -s password
echo "$username:$password" | chpasswd

# Add user to sudoers group
usermod -aG sudo $username

echo "User $username has been created and added to the sudoers group."
