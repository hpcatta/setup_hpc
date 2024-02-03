#!/bin/bash

# Set script to exit on any errors.
set -e

# Define Prometheus version and installation paths
PROMETHEUS_VERSION="2.33.1"
PROMETHEUS_USER="prometheus"
PROMETHEUS_GROUP="prometheus"
INSTALL_DIR="/etc/prometheus"
DATA_DIR="/var/lib/prometheus"
CONFIG_DIR="/etc/prometheus"

# Ensure the script is run as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Create user and group for Prometheus
echo "Creating user and group for Prometheus..."
useradd -rs /bin/false $PROMETHEUS_USER || echo "Prometheus user already exists"
groupadd $PROMETHEUS_GROUP || echo "Prometheus group already exists"

# Download Prometheus
echo "Downloading Prometheus ${PROMETHEUS_VERSION}..."
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz -P /tmp

# Extract Prometheus
echo "Extracting Prometheus..."
tar xvf /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz -C /tmp

# Create directories
echo "Creating Prometheus directories..."
mkdir -p $INSTALL_DIR $DATA_DIR $CONFIG_DIR

# Move configuration files and binaries
echo "Moving Prometheus files..."
cp -r /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64/{prometheus,promtool} $INSTALL_DIR
cp -r /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64/{consoles,console_libraries,prometheus.yml} $CONFIG_DIR

# Set ownership
echo "Setting ownership for Prometheus directories and files..."
chown -R $PROMETHEUS_USER:$PROMETHEUS_GROUP $INSTALL_DIR $DATA_DIR $CONFIG_DIR

# Clean up
echo "Cleaning up..."
rm -rf /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz /tmp/prometheus-${PROMETHEUS_VERSION}.linux-amd64

# Create a Prometheus systemd service file
echo "Creating Prometheus systemd service..."
cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=$PROMETHEUS_USER
Group=$PROMETHEUS_GROUP
Type=simple
ExecStart=$INSTALL_DIR/prometheus \\
  --config.file $CONFIG_DIR/prometheus.yml \\
  --storage.tsdb.path $DATA_DIR \\
  --web.console.templates=$CONFIG_DIR/consoles \\
  --web.console.libraries=$CONFIG_DIR/console_libraries

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to apply new changes and start Prometheus
echo "Starting Prometheus service..."
systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus

echo "Prometheus installation and service setup complete."
echo "Prometheus is now running and accessible on http://localhost:9090"

