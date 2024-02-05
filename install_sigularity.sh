#!/bin/bash

set -e

# Variables
GO_VERSION_REQUIRED="1.20"
GO_VERSION="1.20.1" # Update this to the required version
SINGULARITY_VERSION="main" # Change to a specific version tag as needed
SINGULARITY_DIR="$HOME/singularity"

# Install dependencies
sudo apt-get update
sudo apt-get install -y build-essential libssl-dev uuid-dev libgpgme11-dev squashfs-tools libseccomp-dev wget pkg-config git cryptsetup-bin

# Function to compare version numbers
version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

# Check if Go is installed and at the correct version
if command -v go &> /dev/null; then
    INSTALLED_GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
    if version_gt $GO_VERSION_REQUIRED $INSTALLED_GO_VERSION; then
        NEEDS_GO_INSTALL="yes"
    else
        NEEDS_GO_INSTALL="no"
    fi
else
    NEEDS_GO_INSTALL="yes"
fi

# Install or update Go if necessary
if [ "$NEEDS_GO_INSTALL" = "yes" ]; then
    wget https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz -O go${GO_VERSION}.linux-amd64.tar.gz
    sudo tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
    source ~/.bashrc
    rm go${GO_VERSION}.linux-amd64.tar.gz
fi

# Clone or update Singularity
if [ ! -d "$SINGULARITY_DIR" ]; then
    git clone https://github.com/sylabs/singularity.git $SINGULARITY_DIR
    cd $SINGULARITY_DIR
else
    cd $SINGULARITY_DIR
    git fetch
    git reset --hard origin/$SINGULARITY_VERSION
fi

git checkout $SINGULARITY_VERSION

# Build and install Singularity
./mconfig
cd builddir
make
sudo make install

# Verify installation
singularity version

echo "Singularity installation completed successfully."

