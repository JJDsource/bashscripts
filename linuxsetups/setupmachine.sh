#!/bin/bash

#Run before executing chmod +x setupmachine.sh

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Prompt for hostname
read -p "Enter hostname: " hostname

# Check if hostname is provided
if [[ -z $hostname ]]; then
  echo "Hostname is missing."
  exit 1
fi

# Prompt to confirm hostname
read -p "Confirm hostname: " confirm_hostname

# Check if hostnames match
if [[ "$hostname" != "$confirm_hostname" ]]; then
  echo "Hostnames do not match. Please try again."
  exit 1
fi

# Get the current IP address
current_ip=$(hostname -I | awk '{print $1}')

# Set hostname
echo "$hostname" > /etc/hostname
echo "127.0.0.1 $hostname" >> /etc/hosts
echo "$current_ip $hostname" >> /etc/hosts
hostnamectl set-hostname "$hostname"

# Prompt for username
read -p "Enter username: " username

# Check if username is provided
if [[ -z $username ]]; then
  echo "Username is missing."
  exit 1
fi

# Prompt to confirm username
read -p "Confirm username: " confirm_username

# Check if username match
if [[ "$username" != "$confirm_username" ]]; then
  echo "Username do not match. Please try again."
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
echo "Enter the public key for SSH access:"
read -r public_key

# Prompt to confirm public key
echo "Confirm the public key for SSH access:"
read -r confirm_public_key

# Check if public keys match
if [[ "$public_key" != "$confirm_public_key" ]]; then
  echo "Public keys do not match. Please try again."
  exit 1
fi

# Add public key to authorized_keys file
echo $public_key >> $ssh_dir/authorized_keys
chown $username:$username $ssh_dir/authorized_keys
chmod 600 $ssh_dir/authorized_keys

echo "User $username has been created and added to the sudoers group."
echo "SSH access with the provided public key has been configured."