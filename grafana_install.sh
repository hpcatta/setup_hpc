#!/bin/bash

# Exit script on error
set -e

# Update package list
echo "Updating package list..."
sudo apt-get update

# Install software-properties-common for add-apt-repository
echo "Installing necessary packages..."
sudo apt-get install -y software-properties-common

# Add Grafana GPG key
echo "Adding Grafana GPG key..."
wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -

# Add Grafana repository
echo "Adding Grafana repository..."
echo "deb https://packages.grafana.com/oss/deb stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list

# Update package list again
echo "Updating package list after adding Grafana repository..."
sudo apt-get update

# Install Grafana
echo "Installing Grafana..."
sudo apt-get install -y grafana

# Start and enable Grafana server
echo "Starting and enabling Grafana server..."
sudo systemctl start grafana-server
sudo systemctl enable grafana-server

echo "Grafana installation and deployment complete."
echo "You can access Grafana at http://<your-ip>:3000"

