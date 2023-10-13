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

# Install NVIDIA CUDA Toolkit from Ubuntu repositories
sudo apt install -y nvidia-cuda-toolkit

# After installing, users might want to add CUDA to PATH and LD_LIBRARY_PATH in their .bashrc or .zshrc:
# Note: The paths below might differ depending on the exact installation locations in your system.
# export PATH=/usr/local/cuda/bin:${PATH}
# export LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}

# Print completion message
echo "Installation complete."

