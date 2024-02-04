#!/bin/bash

# Define new UIDs and GID
newUID_rpc=114
newUID_statd=115
newGID=65534 # Shared GID for both users

# 1. Identify the Current UID and GID
echo "Current UID and GID for _rpc:"
id _rpc
echo "Current UID and GID for statd:"
id statd

# 2. Stop Services Using These Users
echo "Stopping NFS and related services..."
sudo systemctl stop nfs-kernel-server rpcbind nfs-lock
# Use nfs-client instead of nfs-kernel-server if it's a client setup

# 3. Change the User ID and Group ID
echo "Updating UIDs and GIDs..."
sudo usermod -u $newUID_rpc -g $newGID _rpc
sudo usermod -u $newUID_statd -g $newGID statd

# 4. Update Filesystem Ownership
# WARNING: This operation will traverse your entire filesystem.
# Limit the search scope to /var, /run, or specific NFS mount points to reduce the scope of changes.
echo "Updating filesystem ownership for _rpc. This might take a while..."
sudo find / -user 114 -exec chown -h $newUID_rpc:$newGID {} \; 2>/dev/null

echo "Updating filesystem ownership for statd. This might take a while..."
sudo find / -user 115 -exec chown -h $newUID_statd:$newGID {} \; 2>/dev/null

# 5. Restart Services
echo "Restarting services..."
sudo systemctl start nfs-kernel-server rpcbind nfs-lock
# Adjust the services based on your setup (nfs-client or nfs-kernel-server)

# 6. Verify
echo "Verifying changes for _rpc..."
id _rpc
echo "Verifying changes for statd..."
id statd

echo "Script execution completed."

