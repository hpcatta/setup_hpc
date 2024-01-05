#!/bin/bash

# Stop MariaDB service
sudo systemctl stop mariadb

# Uninstall MariaDB and purge configuration files
sudo apt-get remove --purge -y mariadb-server mariadb-client

# Remove residual files and dependencies
sudo apt-get autoremove -y
sudo apt-get autoclean

# Remove MariaDB data directories (Warning: This deletes all databases)
sudo rm -rf /var/lib/mysql/

# Remove additional configuration files
sudo rm -rf /etc/mysql/

# Update package lists
sudo apt-get update

# Install MariaDB
sudo apt-get install -y mariadb-server mariadb-client

# Start MariaDB service
sudo systemctl start mariadb

# Enable MariaDB to start on boot
sudo systemctl enable mariadb

# Optional: Secure MariaDB installation
# sudo mysql_secure_installation

echo "MariaDB has been reinstalled and started."

