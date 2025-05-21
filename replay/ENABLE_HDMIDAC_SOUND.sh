#!/bin/bash
set -e

# This utilizes an HDFury3 EDID to enable sound on cheap HDMI to VGA DACS that have a non working AUX port within ReplayOS

# 1. Add EDID firmware to cmdline.txt if not already present
CMDLINE="/boot/firmware/cmdline.txt"
EDID_ARG="drm.edid_firmware=HDMI-A-1:edid/hdf3.bin"

if ! grep -q "$EDID_ARG" "$CMDLINE"; then
    sed -i "1s|^|$EDID_ARG |" "$CMDLINE"
fi

# 2. Create EDID folder and hdf3.bin with binary content
mkdir -p /lib/firmware/edid

base64 -d > /lib/firmware/edid/hdf3.bin <<'EOF'
AP///////wAhbQAAAQAAACUTAQOAAAB4Cg3JoFdHmCcSSEwtywCBgIGPgZmpQEVZYVmBQIFZAR0A
clHQHiBuKFUAxI4hAAAejArQiiDgLRAQPpYAE44hAAAYAAAA/ABIREYzIEVESUQwICAgAAAA/QAX
oA95EQAKICAgICAgAYwCAzBxUoQCAwUGBxAREhMUFRYfICEiAWcDDAAQADgtLAkuBxQEgDwEwDQE
IIMBAAABHYAYcRwWIFgsJQDEjiEAAJ4BHYDQchwWIBAsJYDEjiEAAJ4BHQC8UtAeILgoVUDEjiEA
AB5cLoAYcTgtQFgsRQBYwiGUJBgAAAAAAAAA+Q==
EOF
