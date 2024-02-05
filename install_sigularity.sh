#!/bin/bash

# Stop on error
set -e

# Singularity version to install
SINGULARITY_VERSION=3.8.3 # Change this to the desired version

# Update and install dependencies
sudo apt update
sudo apt install -y build-essential libssl-dev uuid-dev libgpgme11-dev squashfs-tools libseccomp-dev wget pkg-config git cryptsetup-bin

# Download Singularity source code
wget https://github.com/sylabs/singularity/releases/download/v${SINGULARITY_VERSION}/singularity-${SINGULARITY_VERSION}.tar.gz

# Extract Singularity
tar -xzf singularity-${SINGULARITY_VERSION}.tar.gz

# Change to the Singularity source directory
cd singularity-${SINGULARITY_VERSION}

# Compile Singularity
./mconfig
make -C builddir
sudo make -C builddir install

# Cleanup source directory
cd ..
rm -rf singularity-${SINGULARITY_VERSION} singularity-${SINGULARITY_VERSION}.tar.gz

# Verify installation
singularity version

echo "Singularity ${SINGULARITY_VERSION} installation completed successfully."

