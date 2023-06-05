#!/bin/bash
#Run before executing chmod +x setupmachine.sh

# Check if running as root
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# INPUTS
# HOSTNAME
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

# USERNAME
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

# PASSWORD
# Prompt for password
echo "Enter password for user $username:"
read -s password
# Check if password is provided
if [[ -z $password ]]; then
  echo "Password is missing."
  exit 1
fi
# Prompt to confirm password
echo "Confirm password for user $username:"
read -s confirm_password
# Check if passwords match
if [[ "$password" != "$confirm_password" ]]; then
  echo "Passwords do not match. Please try again."
  exit 1
fi

# SSH KEY
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

# GATHERINFO
# Get the current IP address
current_ip=$(hostname -I | awk '{print $1}')

# ACTIONS
# Set hostname
echo "$hostname" > /etc/hostname
echo "127.0.0.1 $hostname" >> /etc/hosts
echo "$current_ip $hostname" >> /etc/hosts
hostnamectl set-hostname "$hostname"
# Add user
useradd -m $username
# Add user to sudoers group
usermod -aG sudo $username
# Remove password prompt for sudo
echo "$username ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
# Set password for the new user
echo "$username:$password" | chpasswd
# Set up SSH with public key
home_dir="/home/$username"
ssh_dir="$home_dir/.ssh"
# Create .ssh directory
mkdir -p $ssh_dir
chown $username:$username $ssh_dir
chmod 700 $ssh_dir
# Add public key to authorized_keys file
echo $public_key >> $ssh_dir/authorized_keys
chown $username:$username $ssh_dir/authorized_keys
chmod 600 $ssh_dir/authorized_keys
# Dont type bash in ssh
echo "exec bash" >> $home_dir/.profile
# Update and upgrade packages install sudo
apt-get update
apt-get upgrade -y
apt-get install -y sudo

# EXIT NOTES
echo "hostanme has been set to $hostname."
echo "User $username has been created and added to the sudoers group."
echo "SSH access with the provided public key has been configured."

# Switch to the new user
su - $username