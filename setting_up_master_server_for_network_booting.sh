#Install Syslinux
#Syslinux includes pxelinux.0, a bootloader for PXE booting.
sudo apt-get -y install syslinux
#Installing DHCP service
sudo apt-get -y install isc-dhcp-server
#configure /etc/dhcp/dhcpd.conf
#If you have configured dhcpd.conf then remove this exit 1
#exit 1
# Function to add a DHCP host configuration
add_dhcp_host() {
    cat <<EOF

    host $1 {
        hardware ethernet $2;
        fixed-address $3;
    }
EOF
}

# Path to DHCPD configuration file
DHCPD_CONF="/etc/dhcp/dhcpd.conf"
TEMP_CONF="dhcpd.conf.new"

# Start building the new configuration segment
cat <<EOF > $TEMP_CONF
default-lease-time 600;
max-lease-time 7200;

# Specify the DNS settings
option domain-name-servers 192.168.168.1;

# Define the subnet
subnet 192.168.168.0 netmask 255.255.255.0 {
    range 192.168.168.100 192.168.168.199; # Dynamic range
    option subnet-mask 255.255.255.0;
    option broadcast-address 192.168.168.255;
    option routers 192.168.168.1; # Gateway
EOF

# Add client configurations
add_dhcp_host "hpc-client-1" "68:05:ca:f3:55:29" "192.168.168.241" >> $TEMP_CONF
add_dhcp_host "hpc-client-2" "68:05:ca:f0:cf:e1" "192.168.168.242" >> $TEMP_CONF
add_dhcp_host "hpc-client-3" "68:05:ca:f0:bc:7b" "192.168.168.243" >> $TEMP_CONF

# Close subnet definition
echo "}" >> $TEMP_CONF

# Backup the original configuration file
cp $DHCPD_CONF "${DHCPD_CONF}.backup"

# Update the DHCPD configuration file
cat $TEMP_CONF > $DHCPD_CONF

# Clean up temporary file
rm $TEMP_CONF

# Restart DHCP service to apply changes
systemctl restart isc-dhcp-server.service

# Check the service status
systemctl status isc-dhcp-server.service -l --no-pager

echo "DHCP configuration has been updated and service restarted."
