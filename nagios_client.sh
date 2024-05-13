#!/bin/bash

# Update the system
sudo apt-get update && sudo apt-get upgrade -y

# Install necessary dependencies
sudo apt-get install -y autoconf gcc libmcrypt-dev make libssl-dev wget

# Optionally create Nagios user and group if not already done
# Uncomment these lines if the user and group are not already set up
#sudo useradd nagios
#sudo groupadd nagcmd
#sudo usermod -a -G nagcmd nagios

# Create directory and download NRPE
mkdir -p /root/nagios
cd /root/nagios
wget --no-check-certificate -O nrpe.tar.gz https://github.com/NagiosEnterprises/nrpe/archive/nrpe-4.1.0.tar.gz
tar xzf nrpe.tar.gz
cd nrpe-nrpe-4.1.0/

# Configure NRPE
sudo ./configure --enable-command-args --with-ssl-lib=/usr/lib/x86_64-linux-gnu/ --with-nrpe-user=nagios --with-nrpe-group=nagcmd

# Compile and install NRPE
sudo make all
sudo make install-plugin
sudo make install-daemon
sudo make install-config

# Update nrpe.cfg to allow your Nagios server
sudo sed -i 's/allowed_hosts=127.0.0.1/allowed_hosts=127.0.0.1,192.168.168.240/' /usr/local/nagios/etc/nrpe.cfg

# Add the Slurm check command
echo "command[check_slurm]=/usr/lib/nagios/plugins/check_slurm.sh" >> /usr/local/nagios/etc/nrpe.cfg

# Copy the Slurm check script
cp -p /data/setup_hpc/check_slurm.sh /usr/lib/nagios/plugins/check_slurm.sh
chmod +x /usr/lib/nagios/plugins/check_slurm.sh

# Enable and start NRPE service
sudo make install-init
sudo systemctl enable nrpe
sudo systemctl start nrpe

# Check the status of the NRPE service
sudo systemctl status nrpe

