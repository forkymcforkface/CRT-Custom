#!/bin/bash

set -e

XONE_INSTALLED=false

# Check if xone is installed
if lsmod | grep -q "^xone"; then
    echo "xone is already installed."
    XONE_INSTALLED=true
else
    echo "xone is not installed. Proceeding with installation..."
    
    echo "Updating package lists..."
    sudo apt update

    echo "Installing dependencies..."
    sudo apt install -y dkms curl cabextract

    echo "Cloning xone repository..."
    git clone https://github.com/forkymcforkface/xone.git ~/xone
    cd ~/xone

    echo "Installing xone..."
    sudo ./install.sh --release
    sudo ./xone-get-firmware.sh --skip-disclaimer

    echo "Installation complete! You can now plug in your Xbox devices."
fi

echo "Set ReplayOS to USB DAC and reboot for headphones to work"
