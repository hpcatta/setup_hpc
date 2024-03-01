#!/bin/bash

# Ensure running as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
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

# Checking for NVIDIA driver installation errors
echo "Checking for NVIDIA driver installation errors..."
dkms status

# Download and install CUDA 11.5
echo "Downloading and installing CUDA 11.5..."
CUDA_REPO_PKG=cuda-repo-ubuntu2004-11-5-local_11.5.1-1_amd64.deb
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/$CUDA_REPO_PKG
sudo dpkg -i $CUDA_REPO_PKG
sudo apt-key add /var/cuda-repo-ubuntu2004-11-5-local/7fa2af80.pub
sudo apt-get update
sudo apt-get -y install cuda-11-5

# Setting up CUDA environment variables
echo "Setting up CUDA environment variables..."
echo 'export PATH=/usr/local/cuda-11.5/bin:$PATH' >> ~/.bashrc
echo 'export LD_LIBRARY_PATH=/usr/local/cuda-11.5/lib64:$LD_LIBRARY_PATH' >> ~/.bashrc
source ~/.bashrc

# Verify CUDA installation
echo "Verifying CUDA installation..."
nvcc --version

# Reboot the system
echo "Installation complete. Please reboot your system."

