#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status


# Check if the first argument is provided, otherwise use the hostname
if [ -z "$1" ]; then
    echo "No client name provided, using the hostname as the client name."
    CLIENT_NAME=$(hostname)
else
    CLIENT_NAME=$1
fi


if ! grep -q 'export PROMPT_COMMAND' /root/.bashrc; then
    echo 'export PROMPT_COMMAND="history -a;$PROMPT_COMMAND"' | sudo tee -a /root/.bashrc
fi

echo "Updating the package list..."
sudo apt-get update

echo "Installing git and binutils..."
sudo apt-get -y install git binutils


echo "Installing build-essential package..."
sudo apt install build-essential -y

# Assuming wget is installed
if ! sudo apt-key list | grep -q "Intel"; then
    echo "Adding Intel GPG Key..."
    wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
    sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB
fi

if [ ! -f "/etc/apt/sources.list.d/oneAPI.list" ]; then
    echo "Adding Intel repository..."
    echo "deb https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list
fi

echo "Updating package list again..."
sudo apt-get update

echo "Installing Intel BaseKit..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold"  intel-basekit

# Check if intel-hpckit is already installed
if dpkg -l | grep -qw intel-hpckit; then
    echo "Intel HPCKit is already installed."
else
    echo "Setting Intel environment variables..."
    source /opt/intel/oneapi/setvars.sh

    echo "Installing Intel HPCKit..."
    sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" intel-hpckit
fi



echo "Setting hostname to $1..."
CURRENT_HOSTNAME=$(hostname)

# Check if the current hostname starts with "hpc-client"
if [[ $CURRENT_HOSTNAME != hpc-client* ]]; then
    echo "Setting hostname to $CLIENT_NAME..."
    hostnamectl set-hostname "$CLIENT_NAME"
else
    echo "Hostname already starts with 'hpc-client', no changes made."
fi

# ... Previous commands

# Checking if MariaDB is installed
if ! dpkg -l | grep mariadb-server > /dev/null 2>&1; then
    echo "Checking Ubuntu version and installing MariaDB..."
    . /etc/os-release
    if [ "$VERSION_ID" == "22.04" ]; then
        sudo DEBIAN_FRONTEND=noninteractive apt install mariadb-server libmariadb-dev-compat libmariadb-dev -y
    else
        sudo apt install mariadb-server libmariadbclient-dev libmariadb-dev -y
    fi
fi



# Defining User and Group IDs
MUNGEUSER=966
SLURMUSER=967


# Checking if group 'munge' exists and has the correct GID
if ! getent group munge > /dev/null 2>&1; then
    echo "Creating munge group..."
    sudo groupadd -g $MUNGEUSER munge
fi

# Checking if user 'munge' exists
if id -u munge > /dev/null 2>&1; then
    # Checking if the existing munge user has the correct UID
    EXISTING_MUNGE_UID=$(id -u munge)
    if [ "$EXISTING_MUNGE_UID" -ne "$MUNGEUSER" ]; then
	echo "Stopping any services using munge user..."
        sudo systemctl stop munge || true  # It's okay if this fails
        echo "Deleting existing munge user with incorrect UID..."
        sudo userdel -r munge
        # Recreate the munge group if it was deleted
        if ! getent group munge > /dev/null 2>&1; then
            echo "Recreating munge group..."
            sudo groupadd -g $MUNGEUSER munge
        fi
    else
        echo "Munge user already exists with correct UID."
    fi
fi

# Creating the munge user with the correct UID if it does not exist
if ! id -u munge > /dev/null 2>&1; then
    echo "Creating munge user..."
    sudo useradd -m -c "MUNGE Uid 'N' Gid Emporium" -d /var/lib/munge -u $MUNGEUSER -g munge -s /sbin/nologin munge
fi

# Setting the correct ownership and permissions for the MUNGE log directory and files
if [ -d "/var/log/munge" ]; then
    echo "Setting permissions for MUNGE log directory..."
    sudo chown -R munge:munge /var/log/munge
    sudo chmod 700 /var/log/munge
fi

if [ -f "/var/log/munge/munged.log" ]; then
    echo "Setting permissions for MUNGE log file..."
    sudo chown munge:munge /var/log/munge/munged.log
    sudo chmod 600 /var/log/munge/munged.log
fi
# Setting the correct ownership and permissions for the MUNGE seed directory
if [ -d "/var/lib/munge" ]; then
    echo "Setting permissions for MUNGE seed directory..."
    sudo chown -R munge:munge /var/lib/munge
    sudo chmod 700 /var/lib/munge
fi
# Setting the correct ownership and permissions for the MUNGE key file
if [ -f "/etc/munge/munge.key" ]; then
    echo "Setting permissions for MUNGE key file..."
    sudo chown -R  munge:munge /etc/munge
    sudo chmod 400 /etc/munge/munge.key
fi


# Checking if group 'slurm' and user 'slurm' exist
if ! getent group slurm > /dev/null 2>&1; then
    echo "Creating slurm group..."
    sudo groupadd -g $SLURMUSER slurm
fi

if ! id -u slurm > /dev/null 2>&1; then
    echo "Creating slurm user..."
    sudo useradd -m -c "SLURM workload manager" -d /var/lib/slurm -u $SLURMUSER -g slurm -s /bin/bash slurm
fi

# Checking if Munge is installed
if ! dpkg -l | grep munge > /dev/null 2>&1; then
    echo "Installing Munge and RNG tools..."
    sudo DEBIAN_FRONTEND=noninteractive apt install munge libmunge-dev libmunge2 rng-tools -y
fi



# Checking if Munge key exists
#if [ ! -f "/etc/munge/munge.key" ]; then
#    echo "Copying Munge key..."
#    cp -rp /data/munge.key /etc/munge/
#fi
cp -rp /data/munge.key /etc/munge/
cp /data/shared_files/hosts /etc/hosts
# Enabling and starting Munge service
echo "Enabling and starting Munge service..."
sudo systemctl enable munge || true
sudo systemctl start munge || true

# Checking Munge service status
echo "Checking Munge service status..."
sudo systemctl status munge
# Install SLURM only if not already installed
if dpkg -l | grep -qw slurm; then
    echo "SLURM is already installed."
else
    echo "Installing SLURM..."
    cd /data/SLURM_BUILD/
    dpkg -i slurm-22.05.9_1.1_amd64.deb
fi

# Check SLURM installation
if command -v slurmctld >/dev/null 2>&1; then
    echo "SLURM is already installed."
else
    echo "Checking SLURM installation..."
    which slurmctld
fi

# Copy SLURM configuration
#if [ -d "/etc/slurm" ]; then
#    echo "SLURM configuration already exists."
#else
#    echo "Copying SLURM configuration..."
#    cp -rp /data/slurm-conf/slurm /etc/
#fi
cp -rp /data/slurm-conf/slurm /etc/

# Create and set permissions for SLURM spool directory
if [ -d "/var/spool/slurm" ]; then
    echo "SLURM spool directory already exists."
else
    echo "Creating and setting permissions for SLURM spool directory..."
    sudo mkdir /var/spool/slurm
    sudo chown slurm:slurm /var/spool/slurm
    sudo chmod 755 /var/spool/slurm
fi

# Create SLURM log files
if [ -f "/var/log/slurm_jobacct.log" ] && [ -f "/var/log/slurm_jobcomp.log" ]; then
    echo "SLURM log files already exist."
else
    echo "Creating SLURM log files..."
    sudo touch /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
    sudo chown slurm: /var/log/slurm_jobacct.log /var/log/slurm_jobcomp.log
fi

# Copy SLURM service file
if [ -f "/etc/systemd/system/slurmd.service" ]; then
    echo "SLURM service file already exists."
else
    echo "Copying SLURM service file..."
    cp -p /data/slurm-conf/slurmd.service /etc/systemd/system/slurmd.service
fi

# Reload systemd daemon
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload
sudo systemctl start munge
# ... rest of the commands with similar checks
# Checking if 'munge' service is running
if systemctl is-active --quiet munge; then
    echo "Munge service is already active."
else
    echo "Starting Munge service..."
    sudo systemctl start munge
fi

# Checking if 'slurmd' service is running
if systemctl is-active --quiet slurmd; then
    echo "Slurmd service is already active."
else
    echo "Starting Slurmd service..."
    sudo systemctl start munge
    sudo systemctl start slurmd
fi
sudo systemctl restart munge
sudo systemctl restart slurmd

echo "Server setup complete."

