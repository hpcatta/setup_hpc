#!/bin/bash

# Set the Node Exporter version to install
NODE_EXPORTER_VERSION="1.3.1"

# Ensure the script is run as root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Download Node Exporter
echo "Downloading Node Exporter version ${NODE_EXPORTER_VERSION}..."
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz -P /tmp

# Extract the tarball
echo "Extracting Node Exporter..."
tar xvfz /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz -C /tmp

# Move the binary to /usr/local/bin
echo "Installing Node Exporter..."
cp /tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter /usr/local/bin

# Cleanup the temporary files
rm -rf /tmp/node_exporter*

# Create a systemd service file for Node Exporter
echo "Creating systemd service for Node Exporter..."
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=default.target
EOF

# Reload systemd, enable and start Node Exporter
echo "Enabling and starting Node Exporter service..."
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

echo "Node Exporter installation and service setup complete."

