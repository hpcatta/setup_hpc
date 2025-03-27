#!/bin/bash

# Step 1: Download CUDA repository pin file for Ubuntu 22.04
echo "Downloading CUDA repository pin..."
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
sudo mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600

# Step 2: Add the GPG keys for the CUDA repository
echo "Adding GPG keys..."
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/7fa2af80.pub || echo "Key 7fa2af80 not fetched."
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub

# Step 3: Add the CUDA repository to the sources list
echo "Adding CUDA repository..."
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /"

# Step 4: Update package lists
echo "Updating package lists..."
sudo apt-get update

# Step 5: Install datacenter-gpu-manager (DCGMI)
echo "Installing datacenter-gpu-manager..."
sudo apt-get install -y datacenter-gpu-manager

# Step 6: Enable and start the NVIDIA DCGM service
echo "Enabling and starting nvidia-dcgm service..."
sudo systemctl --now enable nvidia-dcgm

# Step 7: Install Python3 and pip3 (if not already installed)
echo "Installing Python3 and pip3..."
sudo apt-get install -y python3 python3-pip

# Step 8: Install the ClickHouse connect library for Python
echo "Installing ClickHouse Python client..."
pip3 install clickhouse_connect

# Step 9: Enable DCGMI stats monitoring
echo "Enabling DCGMI stats..."
dcgmi stats --enable

# Step 10: (Optional) Run your data collection Python script
# Uncomment the following lines if you want to run the Python script automatically
# echo "Running data collection script..."
# python3 /path/to/your/collect_data.py

echo "DCGMI installation and setup completed!"

