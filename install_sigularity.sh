#!/bin/bash

# Stop on error
set -e

# Install dependencies
sudo apt-get update && sudo apt-get install -y \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    wget \
    pkg-config \
    git \
    cryptsetup-bin

# Go Version: Replace '1.17' with the version recommended in the INSTALL.md or the version you prefer
GO_VERSION=1.17
wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz
sudo tar -C /usr/local -xzvf go${GO_VERSION}.linux-amd64.tar.gz
export PATH=/usr/local/go/bin:$PATH
echo 'export PATH=/usr/local/go/bin:$PATH' >> ~/.bashrc

# Clone Singularity
git clone https://github.com/sylabs/singularity.git
cd singularity

# Check out the desired version or branch
# Use `git tag` to list all available versions and replace `main` with a specific version if needed
git checkout main

# Compile Singularity
./mconfig
cd builddir
make
sudo make install

# Cleanup
cd ../..
rm -rf singularity go${GO_VERSION}.linux-amd64.tar.gz

# Verify installation
singularity version

echo "Singularity installation completed successfully."

