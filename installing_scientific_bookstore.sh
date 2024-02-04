#!/bin/bash

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install BLAS
echo "Installing BLAS..."
sudo apt-get install -y libblas-dev

# Install FFTW
echo "Installing FFTW..."
sudo apt-get install -y libfftw3-dev

# Install LAPACK
echo "Installing LAPACK..."
sudo apt-get install -y liblapack-dev

# Install ScaLAPACK
# Note: ScaLAPACK requires an MPI implementation. OpenMPI is a common choice.
echo "Installing OpenMPI (dependency for ScaLAPACK)..."
sudo apt-get install -y libopenmpi-dev

echo "Installing ScaLAPACK..."
sudo apt-get install -y libscalapack-openmpi-dev

echo "All requested libraries have been installed."

