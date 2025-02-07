#!/bin/bash

# Define variables
DEVICE="/dev/sda1"
MOUNT_POINT="/media/localdisk"

# Check if the mount point exists, create if not
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point: $MOUNT_POINT"
    sudo mkdir -p "$MOUNT_POINT"
fi

# Check if the device is already mounted at the specified mount point
if mountpoint -q "$MOUNT_POINT"; then
    echo "Device $DEVICE is already mounted at $MOUNT_POINT. No action taken."
else
    echo "Mounting $DEVICE to $MOUNT_POINT..."
    sudo mount "$DEVICE" "$MOUNT_POINT"

    # Verify if the mount was successful
    if mountpoint -q "$MOUNT_POINT"; then
        echo "Successfully mounted $DEVICE at $MOUNT_POINT."
    else
        echo "Failed to mount $DEVICE. Check if the device exists and try again."
    fi
fi