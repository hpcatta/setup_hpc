#!/bin/bash

# Define variables
NHC_VERSION="1.4.3"
INSTALL_PREFIX="/usr/local"
NHC_CONF_DIR="/etc/nhc"
NHC_CONF_FILE="$NHC_CONF_DIR/nhc.conf"

# Step 1: Install Dependencies
echo "Installing required packages..."
sudo apt-get update
sudo apt-get install -y build-essential git

# Step 2: Download NHC
echo "Cloning NHC repository..."
git clone https://github.com/mej/nhc.git nhc-$NHC_VERSION || { echo "Failed to clone NHC repository."; exit 1; }

# Step 3: Install NHC
echo "Installing NHC..."
cd nhc-$NHC_VERSION
sudo make install PREFIX=$INSTALL_PREFIX || { echo "Failed to install NHC."; exit 1; }

# Step 4: Configure NHC
echo "Configuring NHC..."
sudo mkdir -p $NHC_CONF_DIR

# Check if nhc.conf already exists to avoid overwriting
if [ ! -f $NHC_CONF_FILE ]; then
    sudo tee $NHC_CONF_FILE > /dev/null <<EOT
# Example NHC configuration - adjust according to your needs
* || check_fs_mount_rw -t nfs,nfs4,rootfs
* || check_fs_mount_rw -t tmpfs
* || check_fs_df / 10%
* || check_ps_daemon sshd
* || check_ps_daemon crond
EOT
    echo "NHC configuration file created at $NHC_CONF_FILE."
else
    echo "NHC configuration file already exists at $NHC_CONF_FILE. Skipping creation."
fi

echo "NHC installation and basic configuration completed."
echo "Please review $NHC_CONF_FILE to customize NHC checks for your environment."

