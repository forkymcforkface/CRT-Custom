This is a repo of scripts that I use for the underlying replayOS operating system Raspberry Pi OS Bookworm. 


**XBOX Dongle and controller support script**

xone is needed to use the microsoft wireless dongle, and also has better sleep/wakeup support than xpad.

just run this one liner in replayOS ssh and then you can have a more robust xbox controller support installer.

```
wget -qO- https://github.com/forkymcforkface/CRT-Custom/archive/refs/heads/main.zip | busybox unzip -qd /opt/xbox-drv - && cp -r /opt/xbox-drv/CRT-Custom-main/replay/controllers/* /opt/xbox-drv/ && rm -rf /opt/xbox-drv/CRT-Custom-main && chmod -R +x /opt/xbox-drv
```

---------------------------------------------

**HDMI Audio script**

Some HDMI DACs with built-in AUX ports fail to output audio through the AUX jack. I found a workaround that uses an EDID file from a known working DAC. This does not affect video output and is easy to install via SSH. Currently, it only applies to the primary HDMI port and hasn’t been tested with display cloning in replayOS. If this doesn't resolve your HDMI audio issue, consider switching to a DAC known to work.

- SSH into ReplayOS with root/replayos credentials. How to ssh into ReplayOS is on the replayOS Wiki.
- [Go here](https://github.com/forkymcforkface/CRT-Custom/blob/main/replay/HDMI/enable_hdmidac_audio.sh)
- Press copy raw file as seen in this screenshot
<img width="458" height="330" alt="image" src="https://github.com/user-attachments/assets/de262502-a985-4ae0-9e96-b814ed35122b" />

- Paste into the terminal ssh window as seen in this screenshot
<img width="480" height="235" alt="image" src="https://github.com/user-attachments/assets/031c9c95-9594-4879-ba60-de2cf614c2cd" />

- Press enter:
- Rebbot Pi
