#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status


if ! grep -q 'export PROMPT_COMMAND' /root/.bashrc; then
    echo 'export PROMPT_COMMAND="history -a;$PROMPT_COMMAND"' | sudo tee -a /root/.bashrc
fi

echo "Updating the package list..."
sudo apt-get update

echo "Installing git and binutils..."
sudo apt-get -y install git binutils


echo "Installing build-essential package..."
sudo apt install build-essential -y

# Assuming wget is installed
if ! sudo apt-key list | grep -q "Intel"; then
    echo "Adding Intel GPG Key..."
    wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
    sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
fi

if [ ! -f "/etc/apt/sources.list.d/oneAPI.list" ]; then
    echo "Adding Intel repository..."
    echo "deb https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
fi

echo "Updating package list again..."
sudo apt-get update

echo "Installing Intel BaseKit..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  intel-basekit

# Check if intel-hpckit is already installed
if dpkg -l | grep -qw intel-hpckit; then
    echo "Intel HPCKit is already installed."
else
    echo "Setting Intel environment variables..."
    source /opt/intel/oneapi/setvars.sh

    echo "Installing Intel HPCKit..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" intel-hpckit
fi


