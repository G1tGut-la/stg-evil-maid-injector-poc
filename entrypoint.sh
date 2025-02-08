#!/bin/bash

# Exit on any error
set -e

# Execute the first shell script
echo "Executing script/bootload-env.sh..."
chmod +x script/bootload-env.sh
./script/bootload-env.sh

# Execute the second shell script
echo "Executing script/settingUp.sh..."
chmod +x script/settingUp.sh
./script/settingUp.sh

# Execute the Python script
echo "Executing injector/install-injection.py..."
python3 injector/install-injection.py