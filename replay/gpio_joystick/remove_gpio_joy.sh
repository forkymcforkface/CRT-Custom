#!/bin/bash

# 1. Remove compiled gpio-joystick module and overlay
cd /opt/gpio-joy-drv || exit 1
make uninstall

# 2. Re-comment dtoverlay line in /boot/firmware/config.txt
sed -i 's/^\(dtoverlay=gpio-joystick\)/#\1/' /boot/firmware/config.txt

# 3. Remove module autoload configs
rm -f /etc/modules-load.d/gpio-joystick.conf
rm -f /etc/modprobe.d/gpio-joystick.conf

# 4. Remove udev rule
rm -f /etc/udev/rules.d/99-usb-controller.rules

# 5. Remove scripts
rm -f /usr/local/bin/reload_gpio_joystick.sh
rm -f /usr/local/bin/unload_gpio_joystick.sh

# 6. Update initramfs
update-initramfs -u

echo "GPIO joystick setup removed. Reboot recommended."
