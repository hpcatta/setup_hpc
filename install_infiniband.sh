#!/bin/bash

# Update your system
echo "Updating system..."
sudo apt-get update
sudo apt-get upgrade -y

# Install InfiniBand support packages
echo "Installing InfiniBand support packages..."
sudo apt-get install -y infiniband-diags perftest ibutils rdmacm-utils ibverbs-utils

# Install OpenFabrics Enterprise Distribution (OFED)
echo "Installing OpenFabrics Enterprise Distribution (OFED) packages..."
sudo apt-get install -y opensm

# Load the IB kernel modules
echo "Loading InfiniBand kernel modules..."
sudo modprobe ib_cm
sudo modprobe ib_core
sudo modprobe ib_umad
sudo modprobe ib_uverbs

# Verify the modules are loaded
echo "Verifying that InfiniBand kernel modules are loaded..."
lsmod | grep ib_
