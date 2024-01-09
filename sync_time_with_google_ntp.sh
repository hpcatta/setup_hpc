
#!/bin/bash

# Check if the user is root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update and install NTP
echo "Updating packages and installing NTP..."
apt-get update
apt-get install -y ntp

# Backup the current ntp.conf file
echo "Backing up the current /etc/ntp.conf file..."
cp /etc/ntp.conf /etc/ntp.conf.backup

# Configure NTP to use Google's time servers
echo "Configuring NTP to use Google's time servers..."
echo "server time1.google.com iburst" > /etc/ntp.conf
echo "server time2.google.com iburst" >> /etc/ntp.conf
echo "server time3.google.com iburst" >> /etc/ntp.conf
echo "server time4.google.com iburst" >> /etc/ntp.conf

# Restart NTP service
echo "Restarting NTP service..."
systemctl restart ntp

# Disable systemd-timesyncd to avoid conflicts
echo "Disabling systemd-timesyncd service..."
timedatectl set-ntp no

echo "NTP configuration is complete."
