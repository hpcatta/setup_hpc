#!/bin/bash

# Uninstall existing NVIDIA or CUDA drivers
echo "Removing any existing NVIDIA or CUDA drivers..."
sudo apt-get purge nvidia* cuda*
sudo apt-get autoremove

# Update your system
echo "Updating system..."
sudo apt-get update
sudo apt-get upgrade -y

# Install necessary packages for building kernel modules
echo "Installing necessary packages..."
sudo apt-get install -y build-essential dkms

# Add the NVIDIA PPA (Optional, for latest drivers)
echo "Adding the NVIDIA PPA..."
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt-get update

# Automatically install the recommended driver
echo "Installing the recommended NVIDIA driver..."
sudo ubuntu-drivers autoinstall

# Alternatively, if you want to install a specific driver version, you can do:
# sudo apt-get install nvidia-driver-XXX

# Reboot the system
echo "Installation complete. Rebooting the system..."
#sudo reboot

