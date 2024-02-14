#Install Syslinux
#Syslinux includes pxelinux.0, a bootloader for PXE booting.
sudo apt-get -y install syslinux
#Installing DHCP service
sudo apt-get -y install isc-dhcp-server
#configure /etc/dhcp/dhcpd.conf
#If you have configured dhcpd.conf then remove this exit 1
#exit 1
# Function to add a DHCP host configuration
# Function to add a DHCP host configuration
add_dhcp_host() {
    cat <<EOF

    host $1 {
        hardware ethernet $2;
        fixed-address $3;
    }
EOF
}

# Function to add a subnet configuration
add_subnet() {
    cat <<EOF

subnet $1 netmask $2 {
    range $3 $4;
    option routers $5;
    option subnet-mask $2;
    option domain-name-servers $6;
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
option domain-name-servers 192.168.168.240;
EOF

# Define the main subnet
add_subnet "192.168.168.0" "255.255.255.0" "192.168.168.241" "192.168.168.243" "192.168.168.240" "8.8.8.8, 8.8.4.4" >> $TEMP_CONF

# Add client configurations for the main subnet
add_dhcp_host "hpc-client-1" "68:05:ca:f3:55:29" "192.168.168.241" >> $TEMP_CONF
add_dhcp_host "hpc-client-2" "68:05:ca:f0:cf:e1" "192.168.168.242" >> $TEMP_CONF
add_dhcp_host "hpc-client-3" "68:05:ca:f0:bc:7b" "192.168.168.243" >> $TEMP_CONF

# Define additional subnet for ens3f1
add_subnet "10.0.0.0" "255.255.255.0" "10.0.0.2" "10.0.0.4" "10.0.0.1" "8.8.8.8, 8.8.4.4" >> $TEMP_CONF

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

#Setup nfs server for each hpc-client image 
NFS_ROOT="/nfsroot"
NFS_SERVER_IP="192.168.168.240"
CLIENTS=("hpc-client-1" "hpc-client-2" "hpc-client-3")
NFS_CLIENT_IPS="*" ##Assuming allowing it for all clients
mkdir -p $NFS_ROOT
chmod 777 $NFS_ROOT
# Loop through each client to set up their specific NFS root directory
for CLIENT in "${CLIENTS[@]}"; do
    CLIENT_DIR="$NFS_ROOT/$CLIENT"
    echo "Setting up NFS root directory for $CLIENT..."
    mkdir -p "$CLIENT_DIR"
    chmod 777 "$CLIENT_DIR"

    # Append new export for each client to /etc/exports
    echo "$CLIENT_DIR $NFS_CLIENT_IPS(rw,async,no_root_squash,no_subtree_check)" >> /etc/exports
done
exportfs -ra
systemctl restart nfs-kernel-server




#Setting up the tftpd-hpa
apt-get -y install tftpd-hpa

