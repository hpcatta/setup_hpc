#!/bin/bash

# Ensure running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Uninstall existing NVIDIA or CUDA drivers
echo "Removing any existing NVIDIA or CUDA drivers..."
sudo apt-get purge nvidia* cuda* -y
sudo apt-get autoremove -y

# Update your system
echo "Updating system..."
sudo apt-get update
sudo apt-get upgrade -y

# Install necessary packages for building kernel modules
echo "Installing necessary packages..."
sudo apt-get install -y build-essential dkms

# Install Linux headers
echo "Installing Linux headers..."
sudo apt-get install linux-headers-$(uname -r) -y

# Add the NVIDIA PPA (Optional, for latest drivers)
echo "Adding the NVIDIA PPA..."
sudo add-apt-repository ppa:graphics-drivers/ppa -y
sudo apt-get update

# Install NVIDIA driver
echo "Attempting to install NVIDIA driver..."
sudo apt-get install nvidia-driver-545 -y

# Reconfigure DKMS and NVIDIA Driver
echo "Reconfiguring DKMS and NVIDIA driver..."
sudo dpkg-reconfigure nvidia-dkms-545
sudo dpkg-reconfigure nvidia-driver-545

# Check for errors
echo "Checking for installation errors..."
dkms status

# Reboot the system
echo "If no errors are found, please reboot your system manually."

