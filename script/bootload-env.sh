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

#echo "Installing required dependencies..."
apt install -y software-properties-common build-essential \
    zlib1g-dev libssl-dev libncurses5-dev libffi-dev libsqlite3-dev \
    libreadline-dev libbz2-dev liblzma-dev libgdbm-dev tk-dev \
    libdb-dev libexpat1-dev libmpdec-dev libgmp-dev curl wget

echo "Downloading the latest Python source code..."
PYTHON_VERSION=$(curl -s https://www.python.org/ftp/python/ | grep -oE '3\.[0-9]+\.[0-9]+' | sort -V | tail -n1)
PYTHON_TAR="Python-$PYTHON_VERSION.tar.xz"
PYTHON_SRC_DIR="/usr/local/src/Python-$PYTHON_VERSION"

wget "https://www.python.org/ftp/python/$PYTHON_VERSION/$PYTHON_TAR" -P /usr/local/src
tar -xf "/usr/local/src/$PYTHON_TAR" -C /usr/local/src

echo "Building and installing Python $PYTHON_VERSION..."
cd "$PYTHON_SRC_DIR"
./configure --enable-optimizations
make -j$(nproc)
make altinstall

# Check Python version
PYTHON_BIN="/usr/local/bin/python${PYTHON_VERSION%.*}"
echo "Python installed at: $PYTHON_BIN"
$PYTHON_BIN --version

echo "Ensuring pip and venv are installed..."
$PYTHON_BIN -m ensurepip
$PYTHON_BIN -m pip install --upgrade pip

# Ensure the script exists before execution
if [ -f "$PYTHON_SCRIPT_PATH" ]; then
    echo "Executing Python script: $PYTHON_SCRIPT_PATH"
    $PYTHON_BIN "$PYTHON_SCRIPT_PATH"
else
    echo "Python script not found at: $PYTHON_SCRIPT_PATH"
    echo "Please place your script there before running this installer."
fi

echo "Installation complete!"