#!/bin/bash

# Define the custom path for the Python script
PYTHON_SCRIPT_PATH="/opt/install-injection-py/install-injection.py"

# Ensure the script runs as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Please use sudo." 
   exit 1
fi

echo "Updating system packages..."
apt update && apt upgrade -y

echo "Installing required dependencies..."
apt install -y software-properties-common build-essential \
    zlib1g-dev libssl-dev libncurses5-dev libffi-dev libsqlite3-dev \
    libreadline-dev libbz2-dev liblzma-dev libgdbm-dev tk-dev \
    libdb-dev libexpat1-dev libmpdec-dev libgmp-dev curl wget

echo "Installing Python3..."
apt install -y python3

apt install python3-pip -y

echo "Reviewing changes"
echo "Python Version:"
python3 --version 2>/dev/null || echo "Python is not installed"

# Check pip version
echo "Pip Version:"
pip3 --version 2>/dev/null || echo "Pip is not installed"

echo "Installation complete!"