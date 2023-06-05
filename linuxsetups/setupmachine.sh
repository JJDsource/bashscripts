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

# Prompt for password
echo "Enter password for user $username:"
read -s password

# Prompt to confirm password
echo "Confirm password for user $username:"
read -s confirm_password

# Check if passwords match
if [[ "$password" != "$confirm_password" ]]; then
  echo "Passwords do not match. Please try again."
  exit 1
fi

# Add user to sudoers group
usermod -aG sudo $username

# Set up SSH with public key
home_dir="/home/$username"
ssh_dir="$home_dir/.ssh"

# Create .ssh directory
mkdir -p $ssh_dir
chown $username:$username $ssh_dir
chmod 700 $ssh_dir

# Prompt for public key
read -p "Enter the public key for SSH access: " public_key

# Add public key to authorized_keys file
echo $public_key >> $ssh_dir/authorized_keys
chown $username:$username $ssh_dir/authorized_keys
chmod 600 $ssh_dir/authorized_keys

echo "User $username has been created and added to the sudoers group."
echo "SSH access with the provided public key has been configured."

# Logout of root account after 10 seconds
echo "Logging out of the root account in 10 seconds..."
sleep 10
exit
