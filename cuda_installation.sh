#!/bin/bash

# Update the system and install basic utilities
sudo apt update && sudo apt upgrade -y
sudo apt install -y build-essential software-properties-common

# Install GNU GCC and Fortran compilers
sudo apt install -y gcc g++ gfortran

# Install LLVM
sudo apt install -y llvm

# Install BLAS and LAPACK
sudo apt install -y libblas-dev liblapack-dev

# Install FFTW
sudo apt install -y libfftw3-dev

# Install ScalAPACK (this will also install openMPI as a dependency)
sudo apt install -y libscalapack-mpi-dev

# Install NVIDIA GPU drivers
sudo apt install -y nvidia-driver-460

# Install NVIDIA CUDA (assuming you are using Ubuntu 20.04)

# For other versions of Ubuntu, you might need a different repository
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600

# Re-add NVIDIA GPG Key
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub

# Add the repository
sudo add-apt-repository "deb http://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"

# Update package list
sudo apt update

# Install CUDA (this should also install the required NVIDIA GPU drivers)
sudo apt install -y cuda

# After installing, users might want to add CUDA to PATH and LD_LIBRARY_PATH in their .bashrc or .zshrc:
# export PATH=/usr/local/cuda/bin:${PATH}
# export LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}

# Print completion message
echo "Installation complete."

