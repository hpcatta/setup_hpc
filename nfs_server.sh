#!/bin/bash

# Install NFS server
sudo apt update
sudo apt install -y nfs-kernel-server

# Create /data directory in root file system
sudo mkdir -p /data

# Change permissions if needed (you can adjust this as per your requirements)
sudo chmod 777 /data

# Add the /data directory to the NFS export file
echo "/data *(rw,sync,no_subtree_check)" | sudo tee -a /etc/exports

# Restart the NFS server to reflect changes
sudo systemctl restart nfs-kernel-server

# Open the necessary ports in the firewall (assuming you're using UFW)
sudo ufw allow from any to any port nfs

# Print completion message
echo "NFS server setup complete and /data directory exported."

