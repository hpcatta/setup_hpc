#!/bin/bash

# Define new UIDs and GIDs
newUID_rpc=114
newUID_statd=115
newGID=65534

# 1. Identify the Current UID and GID
echo "Fetching current UID for _rpc..."
currentUID_rpc=$(id -u _rpc)
echo "Current UID for _rpc: $currentUID_rpc"

echo "Fetching current UID for statd..."
currentUID_statd=$(id -u statd)
echo "Current UID for statd: $currentUID_statd"

# 2. Stop Services Using These Users
echo "Stopping NFS and related services..."
sudo systemctl stop rpcbind 
# Adjust based on your setup, use nfs-client if applicable

# 3. Change the User ID and Group ID
echo "Updating UIDs and GIDs..."
sudo groupmod -g $newGID _rpc  # Ensure _rpc's group exists; if not, consider adding a group with groupadd
sudo usermod -u $newUID_rpc -g $newGID _rpc
sudo groupmod -g $newGID statd  # Ensure statd's group exists; if not, consider adding a group with groupadd
sudo usermod -u $newUID_statd -g $newGID statd

# 4. Update Filesystem Ownership
echo "Updating filesystem ownership for _rpc..."
sudo find / -user $currentUID_rpc -exec chown -h $newUID_rpc:$newGID {} \; 2>/dev/null
echo "Updating filesystem ownership for statd..."
sudo find / -user $currentUID_statd -exec chown -h $newUID_statd:$newGID {} \; 2>/dev/null

# 5. Restart Services
echo "Restarting services..."
sudo systemctl start  rpcbind
# Adjust the services based on your setup

# 6. Verify
echo "Verifying changes for _rpc..."
id _rpc
echo "Verifying changes for statd..."
id statd

echo "Script execution completed."

