#!/bin/bash

# 1. Compile and install gpio-joystick driver
cd /opt/gpio-joy-drv || exit 1
make all || exit 1
make install || exit 1

# 2. Uncomment dtoverlay in /boot/firmware/config.txt
sed -i 's/^#\(dtoverlay=gpio-joystick\)/\1/' /boot/firmware/config.txt

# 3. Set module to load on boot with options
echo "gpio-joystick" > /etc/modules-load.d/gpio-joystick.conf
echo "options gpio-joystick map=1,2" > /etc/modprobe.d/gpio-joystick.conf
update-initramfs -u

# # uncomment entire section below if you want to disable gpio controllers when a usb controller is plugged in

# # 4. Create udev rule to handle USB joystick detection
# cat <<EOF > /etc/udev/rules.d/99-usb-controller.rules
# SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_INPUT_JOYSTICK}=="1", ACTION=="add", RUN+="/usr/local/bin/unload_gpio_joystick.sh"
# SUBSYSTEM=="input", ENV{ID_BUS}=="usb", ENV{ID_INPUT_JOYSTICK}=="1", ACTION=="remove", RUN+="/usr/local/bin/reload_gpio_joystick.sh"
# EOF

# # 5. Create unload script when usb controller is plugged in
# cat <<'EOF' > /usr/local/bin/unload_gpio_joystick.sh
# #!/bin/bash
# /sbin/rmmod gpio_joystick 2>/dev/null
# EOF
# chmod +x /usr/local/bin/unload_gpio_joystick.sh

# # 6. Create reload script when usb controller is unplugged
# cat <<'EOF' > /usr/local/bin/reload_gpio_joystick.sh
# #!/bin/bash
# sleep 2
# if ! ls /dev/input/by-id/*-joystick 2>/dev/null | grep -q .; then
  # /sbin/modprobe gpio_joystick map=1,2
# fi
# EOF
# chmod +x /usr/local/bin/reload_gpio_joystick.sh

# sync
# sudo reboot
