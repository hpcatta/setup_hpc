#!/bin/bash

# Nodes to copy files to
NODES=("hpc-admin-1" "hpc-admin-2" "hpc-admin-3")

# Prompt user for the username to add
read -p "Enter the username to add: " USERNAME

# Check if the user already exists
if id "$USERNAME" &>/dev/null; then
    echo "User $USERNAME already exists. Exiting."
    exit 1
fi

# Add the user
sudo adduser $USERNAME

# Check if user addition was successful
if [ $? -ne 0 ]; then
    echo "Failed to add user $USERNAME. Exiting."
    exit 1
fi

# Copy necessary files to nodes
for NODE in "${NODES[@]}"; do
    echo "Copying files to $NODE..."
    
    # Copy /etc/passwd
    sudo scp /etc/passwd $NODE:/etc/passwd

    # Copy /etc/shadow
    sudo scp /etc/shadow $NODE:/etc/shadow

    # Copy /etc/group
    sudo scp /etc/group $NODE:/etc/group

    # Copy /etc/gshadow
    sudo scp /etc/gshadow $NODE:/etc/gshadow

    echo "Files copied to $NODE successfully."
done

echo "User management tasks completed."

