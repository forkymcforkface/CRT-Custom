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
sudo sed -i '/^\s*blacklist\s\+xpad\s*$/d' /etc/modprobe.d/xone-blacklist.conf
rm -rf /usr/src/xpad-0.4
git clone https://github.com/forkymcforkface/xpad-noone.git /usr/src/xpad-0.4
cd /usr/src/xpad-0.4

echo ">> Uninstalling xpad module..."
dkms remove -m xpad -v 0.4 --all || true

echo ">> Installing xpad module..."
dkms install -m xpad -v 0.4 --force
sudo modprobe xpad

echo ">> Done. Custom xpad driver patched and installed, please reboot."
