#!/bin/bash

# Define variables
INSTALL_DIR=/data/lmod

# Check if Lmod directory exists
if [ ! -d "${INSTALL_DIR}" ]; then
    echo "Lmod directory (${INSTALL_DIR}) does not exist. Please check the shared path."
    exit 1
fi

# Install Lua and other dependencies locally (if necessary)
echo "Ensuring local dependencies are met..."
sudo apt-get update
sudo apt-get install -y lua-posix lua-filesystem lua-json lua-term luajit

# Setup environment for Lmod
echo "Setting up environment for Lmod..."
if [ ! -f /etc/profile.d/lmod.sh ]; then
    echo "# Lmod Setup" | sudo tee /etc/profile.d/lmod.sh
    echo "source ${INSTALL_DIR}/lmod/8.6/init/bash" | sudo tee -a /etc/profile.d/lmod.sh
else
    echo "Lmod environment script already exists."
fi

echo "Client setup completed. Please, log out and log back in or source /etc/profile.d/lmod.sh to start using Lmod."

