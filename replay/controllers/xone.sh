#!/bin/bash
set -e

# --- Install required packages silently ---
echo ">> Installing required packages..."
export DEBIAN_FRONTEND=noninteractive
sudo apt update -qq
sudo apt install -y -qq git dkms build-essential patch libasound2-dev usbutils

cd /opt/xbox-drv

echo ">> Cloning/updating xone repo..."
if [ -d xone ]; then
    cd xone
    git pull
else
    git clone https://github.com/dlundqvist/xone
    cd xone
fi

echo ">> Installing xone module..."
sudo make install

echo ">> Done. Custom xone driver patched and installed."

echo ">> Installing xpad-noone to allow xone to manage xbox one controllers"
echo ">> Cloning/updating xpad repo..."

sudo modprobe -r xpad xpad-noone || true
if [ -d /usr/src/xpad-noone-1.0 ]; then
    sudo git -C /usr/src/xpad-noone-1.0 pull
else
    sudo git clone https://github.com/forkymcforkface/xpad-noone.git /usr/src/xpad-noone-1.0
fi
sudo dkms install -m xpad-noone -v 1.0
echo 'xpad-noone' | sudo tee /etc/modules-load.d/xpad-noone.conf
sudo modprobe xpad-noone

echo ">> Done. Custom xpad driver patched and installed, please reboot."
