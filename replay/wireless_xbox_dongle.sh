#!/bin/bash

set -e

# Check if xone is installed
if lsmod | grep -q "^xone"; then
    echo "xone is already installed."
else
    echo "xone is not installed. Proceeding with installation..."

    echo "Updating package lists..."
    sudo apt update

    echo "Installing dependencies..."
    sudo apt install -y git dkms curl cabextract

    echo "Cloning xone repository..."
    git clone https://github.com/forkymcforkface/xone.git ~/xone
    cd ~/xone

    echo "Installing xone..."
    sudo ./install.sh --release
    sudo xone-get-firmware.sh --skip-disclaimer

    echo "Installation complete! You can now plug in your Xbox devices."
fi

# Install custom xpad driver
echo "Installing custom xpad module..."

sudo rm -rf /usr/src/xpad-0.4
sudo git clone https://github.com/forkymcforkface/xpad-noone-ms /usr/src/xpad-0.4

# Remove old xpad module from kernel if exists
sudo find /lib/modules/$(uname -r) -name 'xpad.ko*' -exec rm -v {} \;

# Force install DKMS module
sudo dkms install xpad/0.4 --force

# Update initramfs
echo "Updating initramfs..."
sudo update-initramfs -u

echo "Set ReplayOS to USB DAC and reboot for controller aux port to work"

sleep 3
sudo reboot
