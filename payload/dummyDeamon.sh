#!/bin/bash

# Define log file (optional)
LOGFILE="/var/log/dummy_daemon.log"

# Function to handle shutdown signals
cleanup() {
    echo "$(date) - Dummy daemon stopping..." | tee -a "$LOGFILE"
    exit 0
}

# Trap signals to allow clean shutdown
trap cleanup SIGTERM SIGINT

# Log start time
echo "$(date) - Dummy daemon started" | tee -a "$LOGFILE"

# Infinite loop with minimal resource usage
while true; do
    sleep 60  # Sleep for 60 seconds to avoid high CPU usage
done