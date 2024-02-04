#!/bin/bash

# Define variables
LUA_VERSION=5.3
LMOD_VERSION=8.6
INSTALL_DIR=/data/lmod

# Update and install dependencies
echo "Updating package list and installing dependencies..."
sudo apt-get update
sudo apt-get install -y lua${LUA_VERSION} lua-posix lua-filesystem lua-json lua-term luajit liblua${LUA_VERSION}-dev make gcc

# Download Lmod
echo "Downloading Lmod..."
cd /tmp
wget https://github.com/TACC/Lmod/archive/refs/tags/${LMOD_VERSION}.tar.gz

# Extract Lmod
echo "Extracting Lmod..."
tar -xzf ${LMOD_VERSION}.tar.gz

# Compile and Install Lmod
echo "Compiling and installing Lmod to ${INSTALL_DIR}..."
cd Lmod-${LMOD_VERSION}
./configure --prefix=${INSTALL_DIR} --with-fastTCLInterp=no
make install

# Setup environment for Lmod (this step is now handled on client nodes)
echo "Installation completed. Lmod is installed in ${INSTALL_DIR}."
echo "Remember to set up the environment on client nodes."

