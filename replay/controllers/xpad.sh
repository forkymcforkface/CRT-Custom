#!/bin/bash
set -e

echo ">> Cloning xpad repo..."
sudo rm -rf /usr/src/xpad-0.4
sudo git clone https://github.com/paroj/xpad.git /usr/src/xpad-0.4
cd /usr/src/xpad-0.4

echo ">> Applying patch to block official Xbox One controllers..."
sudo patch -p1 <<'EOF'
diff --git a/xpad.c b/xpad.c
index afacca8..f8fcd80 100644
--- a/xpad.c
+++ b/xpad.c
@@ -78,6 +78,7 @@
 #define ABS_PROFILE ABS_MISC
 #endif

+#define IS_MS_XBOXONE(idVendor, xtype) ((idVendor) == 0x045e && (xtype) == XTYPE_XBOXONE)
 #define XPAD_PKT_LEN 64

 /* The Guitar Hero Live (GHL) Xbox One dongles require a poke 
@@ -2346,6 +2347,11 @@ static int xpad_probe(struct usb_interface *intf, const struct usb_device_id *id
 	xpad->intf = intf;
 	xpad->mapping = xpad_device[i].mapping;
 	xpad->xtype = xpad_device[i].xtype;
+	if (IS_MS_XBOXONE(le16_to_cpu(udev->descriptor.idVendor), xpad->xtype)) {
+	    dev_info(&intf->dev, "Blocking official Xbox One controller\n");
+	    error = -ENODEV;
+	    goto err_free_in_urb;
+	}
 	xpad->name = xpad_device[i].name;
 	xpad->quirks = xpad_device[i].quirks;
 	xpad->packet_type = PKT_XB;
EOF

echo ">> Rebuilding DKMS module..."
sudo dkms remove -m xpad -v 0.4 --all || true
sudo dkms add -m xpad -v 0.4
sudo dkms build -m xpad -v 0.4
sudo dkms install -m xpad -v 0.4 --force

echo ">> Reloading module..."
sudo modprobe -r xpad || true
sudo modprobe xpad

echo ">> Done. Custom xpad module loaded."
