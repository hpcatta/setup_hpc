#!/bin/bash

# Ensure running as root
if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Step 1: Uninstall existing NVIDIA drivers
echo "Removing existing NVIDIA drivers..."
sudo apt-get purge nvidia* -y
sudo apt-get autoremove -y

# Step 2: Add the NVIDIA driver repository
echo "Adding NVIDIA driver repository..."
sudo add-apt-repository ppa:graphics-drivers/ppa -y
sudo apt-get update

# Step 3: Install NVIDIA driver 470
echo "Installing NVIDIA driver 470..."
sudo apt-get install nvidia-driver-470 -y

# Step 4: Reboot the system
echo "Installation complete. Rebooting the system..."
#sudo reboot

