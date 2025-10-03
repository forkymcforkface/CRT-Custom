#!/bin/bash
set -e

# --- Helper function to check for internet ---
check_internet() {
    ping -q -c 1 -W 1 github.com >/dev/null 2>&1
}

# --- Install required packages silently ---
echo ">> Installing required packages..."
export DEBIAN_FRONTEND=noninteractive
if check_internet; then
    sudo apt update -qq || true
    sudo apt install -y -qq git dkms build-essential patch libasound2-dev usbutils || true
else
    echo "No internet detected. Skipping package installation."
fi

cd /opt/xbox-drv

# --- xone ---
echo ">> Copying firmware..."
sudo cp -v firmware/* /lib/firmware/ || true

echo ">> Updating xone repo..."
if check_internet; then
    git -C xone pull || true
fi

echo ">> Installing xone module..."
sudo make -C xone install || true

# --- xpad-noone ---
echo ">> Updating xpad-noone repo..."
if check_internet; then
    git -C xpad-noone-1.0 pull || true
fi

sudo modprobe -r xpad xpad-noone || true
sudo rsync -a --delete xpad-noone-1.0/ /usr/src/xpad-noone-1.0/ || true
sudo dkms install -m xpad-noone -v 1.0 --force || true

echo ">> Loading xpad-noone module..."
echo 'xpad-noone' | sudo tee /etc/modules-load.d/xpad-noone.conf >/dev/null
sudo modprobe xpad-noone || true
