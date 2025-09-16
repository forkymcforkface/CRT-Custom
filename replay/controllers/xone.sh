#!/bin/bash
set -e

# --- Install required packages silently ---
echo ">> Installing required packages..."
export DEBIAN_FRONTEND=noninteractive
sudo apt update -qq
sudo apt install -y -qq git dkms build-essential patch libasound2-dev usbutils

cd /opt/xbox-drv

echo ">> Cloning xone repo..."
rm -rf xone
git clone https://github.com/dlundqvist/xone
cd xone

echo ">> Uninstalling xone module..."
modprobe -r xone_gip_headset xone_gip_gamepad xone_dongle xone_gip || true
./uninstall.sh

echo ">> Installing xone module..."
./install.sh --release

echo ">> Installing firmware..."
./install/firmware.sh --skip-disclaimer

echo ">> Done. Custom xone driver patched and installed."


echo ">> Installing xpad-noone to allow xone to manage xbox one controllers"
echo ">> Cloning xpad repo..."

sudo modprobe -r xpad xpad-noone || true
sudo git clone https://github.com/forkymcforkface/xpad-noone.git /usr/src/xpad-noone-1.0
sudo dkms install -m xpad-noone -v 1.0
echo 'xpad-noone' | sudo tee /etc/modules-load.d/xpad-noone.conf
sudo modprobe xpad-noone

echo ">> Done. Custom xpad driver patched and installed, please reboot."
