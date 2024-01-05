#!/bin/bash

# Stop MariaDB service
sudo systemctl stop mariadb

# Uninstall MariaDB and purge configuration files
sudo apt-get remove --purge -y mariadb-server mariadb-client

# Remove residual files and dependencies
sudo apt-get autoremove -y
sudo apt-get autoclean

# Optional: Remove MariaDB data directories (Warning: This deletes all databases)
sudo rm -rf /var/lib/mysql/

# Optional: Remove additional configuration files
sudo rm -rf /etc/mysql/

