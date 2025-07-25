#!/bin/bash
set -e

echo ">> Cloning xone repo..."
rm -rf xone
git clone https://github.com/dlundqvist/xone
cd xone

echo ">> Applying patch to enable Aux audio, and to only manage official xone wired contollers"
patch -p1 <<'EOF'
diff --git a/driver/headset.c b/driver/headset.c
index 4c6e73e..d388e3b 100644
--- a/driver/headset.c
+++ b/driver/headset.c
@@ -14,7 +14,7 @@
 #include "common.h"
 #include "../auth/auth.h"
 
-#define GIP_HS_NAME "Microsoft Xbox Headset"
+#define GIP_HS_NAME "USB Audio"
 
 #define GIP_HS_NUM_BUFFERS 128
 
@@ -31,6 +31,7 @@ static const struct snd_pcm_hardware gip_headset_pcm_hw = {
 		SNDRV_PCM_INFO_INTERLEAVED |
 		SNDRV_PCM_INFO_BLOCK_TRANSFER,
 	.formats = SNDRV_PCM_FMTBIT_S16_LE,
+	.rates = SNDRV_PCM_RATE_48000,
 	.rates = SNDRV_PCM_RATE_CONTINUOUS,
 	.periods_min = 2,
 	.periods_max = GIP_HS_NUM_BUFFERS,
@@ -374,15 +375,13 @@ static void gip_headset_register(struct work_struct *work)
 		return;
 	}
 
-	/* set hardware volume to maximum for headset jack */
 	/* standalone & chat headsets have physical volume controls */
-	if (client->id && !headset->chat_headset) {
-		err = gip_set_audio_volume(client, 100, 50, 100);
-		if (err) {
-			dev_err(&client->dev, "%s: set volume failed: %d\n",
+	/* Reduce default volume for all connected audio devices (both headsets and headphones) */
+	err = gip_set_audio_volume(client, 60, 50, 60); // Reduce max headphone volume by 40% since its VERY loud be default
+	if (err) {
+		dev_err(&client->dev, "%s: set volume failed: %d\n",
 				__func__, err);
-			return;
-		}
+		return;
 	}
 
 	err = gip_init_audio_out(client);
diff --git a/install.sh b/install.sh
index 45d56fd..dcf3c23 100755
--- a/install.sh
+++ b/install.sh
@@ -44,11 +44,6 @@ if dkms install -m xone -v "$version"; then
     # The blacklist should be placed in /usr/local/lib/modprobe.d for kmod 29+
     install -D -m 644 install/modprobe.conf /etc/modprobe.d/xone-blacklist.conf
 
-    # Avoid conflicts between xpad and xone
-    if lsmod | grep -q '^xpad'; then
-        modprobe -r xpad
-    fi
-
     # Avoid conflicts between mt76x2u and xone
     if lsmod | grep -q '^mt76x2u'; then
         modprobe -r mt76x2u
diff --git a/install/modprobe.conf b/install/modprobe.conf
index 21855c8..11da85a 100644
--- a/install/modprobe.conf
+++ b/install/modprobe.conf
@@ -1,2 +1 @@
-blacklist xpad
 blacklist mt76x2u
diff --git a/transport/wired.c b/transport/wired.c
index 1872f31..b394ff8 100644
--- a/transport/wired.c
+++ b/transport/wired.c
@@ -475,6 +475,10 @@ static int xone_wired_init_audio_port(struct xone_wired *wired)
 static int xone_wired_probe(struct usb_interface *intf,
 			    const struct usb_device_id *id)
 {
+	/* Only allow Microsoft vendor devices (0x045e) */
+	if (id->idVendor != 0x045e)
+		return -ENODEV;
+
 	struct xone_wired *wired;
 	int err;
EOF

echo ">> Uninstalling xone module..."
systemctl restart replay
modprobe -r xone_gip_headset xone_gip_gamepad xone_dongle xone_gip
sudo ./uninstall.sh

echo ">> Installing xone module..."
sudo ./install.sh --release

echo ">> Installing firmware..."
sudo ./install/firmware.sh --skip-disclaimer

echo ">> Done. xone patched and installed."
sudo reboot
