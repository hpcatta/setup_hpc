#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Define variables
NODE_EXPORTER_VERSION="1.3.1"
PROMETHEUS_CONFIG_FILE="/etc/prometheus/prometheus.yml"
GRAFANA_DATASOURCE_PATH="/etc/grafana/provisioning/datasources/prometheus.yml"

# Ensure the script is run as root
if [[ "$(id -u)" -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

# Step 1: Install Node Exporter
echo "Downloading and installing Node Exporter..."
wget "https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz" -P /tmp
tar xvf "/tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz" -C /tmp/
cp "/tmp/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64/node_exporter" /usr/local/bin/
useradd -rs /bin/false node_exporter

# Create systemd service file for Node Exporter
cat <<EOF > /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Node Exporter
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter
echo "Node Exporter installed and started."

# Step 2: Configure Prometheus to scrape Node Exporter
echo "Configuring Prometheus to scrape Node Exporter..."
if ! grep -q "node_exporter" "${PROMETHEUS_CONFIG_FILE}"; then
    sed -i '/scrape_configs:/a \
  - job_name: "node_exporter"\n\
    static_configs:\n\
    - targets: ["localhost:9100"]' "${PROMETHEUS_CONFIG_FILE}"
    systemctl restart prometheus
    echo "Prometheus configuration updated to scrape Node Exporter."
else
    echo "Prometheus already configured to scrape Node Exporter."
fi

# Step 3: Configure Grafana to use Prometheus as a data source
echo "Configuring Grafana to use Prometheus as a data source..."
mkdir -p $(dirname "${GRAFANA_DATASOURCE_PATH}")
cat <<EOF > "${GRAFANA_DATASOURCE_PATH}"
apiVersion: 1

datasources:
- name: Prometheus
  type: prometheus
  access: proxy
  url: http://localhost:9090
  isDefault: true
EOF

# Restart Grafana to apply changes
systemctl restart grafana-server
echo "Grafana configured to use Prometheus."

echo "Setup complete. CPU and memory charts can now be visualized in Grafana using Prometheus data."

