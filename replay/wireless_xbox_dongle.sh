#!/bin/bash

set -e

ASOUND_FILE="$HOME/.asoundrc"
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
    sudo apt install -y dkms curl cabextract linux-headers-$(uname -r)

    echo "Cloning xone repository..."
    git clone https://github.com/dlundqvist/xone.git ~/xone
    cd ~/xone

    echo "Installing xone..."
    sudo ./install.sh --release

    echo "Downloading firmware for the wireless dongle..."
    sudo ./xone-get-firmware.sh --skip-disclaimer

    echo "Installation complete! You can now plug in your Xbox devices."
fi

# Prompt for enabling/disabling the headphone port
while true; do
    echo ""
    echo "Would you like to enable (y) or disable (n) the headphone port on the controller?"
    read -r choice

    if [[ "$choice" == "y" ]]; then
        echo "Enabling Xbox controller headphone port..."
        cat <<EOL > "$ASOUND_FILE"
pcm.xbox {
    type hw
    card 2
    device 0
}

ctl.xbox {
    type hw
    card 2
}

pcm.!default pcm.xbox
ctl.!default ctl.xbox
EOL
        echo "Headphone port enabled."
        break
    elif [[ "$choice" == "n" ]]; then
        echo "Disabling Xbox controller headphone port..."
        rm -f "$ASOUND_FILE"
        echo "Headphone port disabled."
        break
    else
        echo "Invalid input. Please enter 'y' to enable or 'n' to disable."
    fi
done

echo "Done!"
