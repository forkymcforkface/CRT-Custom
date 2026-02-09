#!/bin/bash

set -e  # Exit on any command failure

# Configuration variables
I2C_BUS=13
I2C_ADDRESS=0x78
PAGE_REGISTER=0x00
EDID_PAGE=0x07
WAKEUP_PAGE=0x09
ENABLEADD_PAGE=0x06
EDID_START_REGISTER=0x80
CSYNC_PAGE=0x04
CSYNC_REGISTER=0xB5

# Wakeup registers
ENABLEADD_REGISTER=0x05

# Wakeup registers
WAKEUP_REGISTER1=0x16
WAKEUP_REGISTER2=0x17

# Set the register to 0
REGISTER_ZERO=0x00

# Sync Type Configuration
SYNC_SEPARATED=0x00
CSYNC_AND=0x06
CSYNC_XOR=0x0C

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root."
    exit 1
fi

# Load the i2c-dev kernel module
if ! lsmod | grep -q '^i2c_dev'; then
    echo "Loading i2c-dev kernel module..."
    modprobe i2c-dev
fi

# Enable CSYNC
echo "Enabling CSYNC..."
i2cset -a -y "$I2C_BUS" "$I2C_ADDRESS" "$PAGE_REGISTER" "$CSYNC_PAGE"
i2cset -a -y "$I2C_BUS" "$I2C_ADDRESS" "$CSYNC_REGISTER" "$CSYNC_AND"

echo "Process completed successfully."

