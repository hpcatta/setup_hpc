#!/bin/bash

# Update system
sudo apt update

# Install prerequisites
sudo apt install -y wget

# Check and install Prometheus
if ! command -v prometheus &> /dev/null; then
    echo "Installing Prometheus..."
    wget https://github.com/prometheus/prometheus/releases/download/v2.31.1/prometheus-2.31.1.linux-amd64.tar.gz
    tar xvf prometheus-2.31.1.linux-amd64.tar.gz
    sudo cp prometheus-2.31.1.linux-amd64/prometheus /usr/local/bin/
    sudo cp prometheus-2.31.1.linux-amd64/promtool /usr/local/bin/
fi

# Ensure Prometheus directories exist
sudo mkdir -p /etc/prometheus
sudo mkdir -p /var/lib/prometheus

# Set up Prometheus service if it doesn't exist
if [ ! -f "/etc/systemd/system/prometheus.service" ]; then
    sudo bash -c 'cat << EOF > /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF'
fi

# Ensure Prometheus user exists and set permissions
if ! id "prometheus" &>/dev/null; then
    sudo useradd -rs /bin/false prometheus
fi
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown -R prometheus:prometheus /var/lib/prometheus

# Ensure basic Prometheus configuration exists
if [ ! -f "/etc/prometheus/prometheus.yml" ]; then
    sudo bash -c 'cat << EOF > /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']
  - job_name: 'node_exporter'
    static_configs:
    - targets: ['client_node_ip:9100']  # Replace client_node_ip with the IP of your client node
EOF'
fi

# Start Prometheus if not running
if ! systemctl is-active --quiet prometheus; then
    sudo systemctl start prometheus
    sudo systemctl enable prometheus
fi

# Install Grafana if not installed
if ! dpkg -l | grep -qw grafana; then
    echo "Installing Grafana..."
    sudo add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
    wget -q -O - https://packages.grafana.com/gpg.key | sudo apt-key add -
    sudo apt update
    sudo apt install grafana
    sudo systemctl start grafana-server
    sudo systemctl enable grafana-server
fi

echo "Master setup complete."

