#!/bin/bash

# Update system packages
sudo apt-get update

# Install Docker Engine
sudo apt-get install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Install NVIDIA GPU Drivers (assumes you want the latest version)
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt-get update
sudo ubuntu-drivers autoinstall

# Install NVIDIA Container Toolkit
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# Install GDRCopy for HPL Benchmark
git clone https://github.com/NVIDIA/gdrcopy.git
cd gdrcopy
sudo apt-get install -y build-essential checkinstall debhelper dkms
make PREFIX=/usr/local CUDA=/usr/local/cuda
sudo checkinstall -D --install --pkgname=gdrcopy --nodoc --pkgversion=$(date +'%Y%m%d%H%M%S')

# Load GDRCopy kernel module
sudo modprobe gdrdrv

