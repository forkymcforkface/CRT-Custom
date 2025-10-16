#!/bin/bash
set -e

clear
echo "--- Custom EDID Generator ---"
echo "" # Add a blank line for spacing

# --- USER INPUT ---

# 1. Manufacturer ID
while true; do
    read -p "Enter a 3-letter Manufacturer ID (e.g., HKM, PNY, HDF): " new_mfg
    if [[ "$new_mfg" =~ ^[A-Z]{3}$ ]]; then
        break
    else
        echo "Error: Input must be exactly 3 uppercase letters (A-Z)."
    fi
done

# 2. Monitor Name
read -p "Enter new monitor name (up to 13 characters): " new_name
if [ ${#new_name} -gt 13 ]; then
    echo "Error: Name is longer than 13 characters."
    exit 1
fi
padded_name=$(printf "%-13.13s" "$new_name")


# --- DATA PROCESSING ---

# Original HDFury3 EDID data
original_base64="AP///////wAhbQAAAQAAACUTAQOAAAB4Cg3JoFdHmCcSSEwtywCBgIGPgZmpQEVZYVmBQIFZAR0AclHQHiBuKFUAxI4hAAAejArQiiDgLRAQPpYAE44hAAAYAAAA/ABIREYzIEVESUQwICAgAAAA/QAXoA95EQAKICAgICAgAYwCAzBxUoQCAwUGBxAREhMUFRYfICEiAWcDDAAQADgtLAkuBxQEgDwEwDQEIIMBAAABHYAYcRwWIFgsJQDEjiEAAJ4BHYDQchwWIBAsJYDEjiEAAJ4BHQC8UtAeILgoVUDEjiEAAB5cLoAYcTgtQFgsRQBYwiGUJBgAAAAAAAAA+Q=="

# Create a temporary binary file
temp_file="/tmp/edid.tmp"
echo "$original_base64" | base64 -d > "$temp_file"

# --- 1. Modify Manufacturer ID (Bytes 8-9) ---
echo "Processing Manufacturer ID..."
# Convert 3 letters into two 8-bit bytes according to EDID spec
char1=${new_mfg:0:1}
char2=${new_mfg:1:1}
char3=${new_mfg:2:1}

# Get 5-bit value for each char (A=1, B=2, ...)
val1=$(( $(printf "%d" "'$char1") - 64 ))
val2=$(( $(printf "%d" "'$char2") - 64 ))
val3=$(( $(printf "%d" "'$char3") - 64 ))

# Pack the three 5-bit values into a 16-bit integer and split into two bytes
byte1=$(( (val1 << 2) | (val2 >> 3) ))
byte2=$(( ((val2 & 7)) << 5 | val3 ))

# Write the two new bytes to the file at offsets 8 and 9
printf "\\$(printf '%03o' "$byte1")" | dd of="$temp_file" bs=1 seek=8 conv=notrunc &>/dev/null
printf "\\$(printf '%03o' "$byte2")" | dd of="$temp_file" bs=1 seek=9 conv=notrunc &>/dev/null

# --- 2. Modify Monitor Name (Bytes 95-107) ---
echo "Processing Monitor Name..."
printf "%s" "$padded_name" | dd of="$temp_file" bs=1 seek=95 conv=notrunc &>/dev/null

# --- 3. Recalculate and write the checksum ---
echo "Recalculating checksum..."
sum=0
for byte in $(od -An -t u1 -N 127 "$temp_file"); do
    sum=$((sum + byte))
done
checksum=$(( (256 - (sum % 256)) % 256 ))
printf "\\$(printf '%03o' "$checksum")" | dd of="$temp_file" bs=1 seek=127 conv=notrunc &>/dev/null
echo "New checksum is: $checksum"

# Re-encode the modified binary file back to base64
new_base64=$(base64 -w 0 "$temp_file")
rm "$temp_file"

# --- INSTALLATION ---
CMDLINE="/boot/firmware/cmdline.txt"
EDID_ARG="drm.edid_firmware=HDMI-A-1:edid/edid.bin"

if ! grep -q "$EDID_ARG" "$CMDLINE"; then
    echo "Adding EDID argument to $CMDLINE"
    sudo sed -i "1s|^|$EDID_ARG |" "$CMDLINE"
fi

echo "Creating custom EDID file..."
sudo mkdir -p /lib/firmware/edid
sudo bash -c "base64 -d > /lib/firmware/edid/edid.bin" <<EOF
$new_base64
EOF

echo ""
echo "The EDID has been updated and a valid checksum was written."
echo "A reboot is required for changes to take effect."
