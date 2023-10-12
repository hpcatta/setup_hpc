#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

echo "Updating the package list..."
sudo apt-get update

echo "Installing OpenMPI..."
sudo apt-get install -y libopenmpi-dev openmpi-bin

