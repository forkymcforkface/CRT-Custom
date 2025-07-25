This is a repo of scripts that I use for the underlying replayOS operating system Raspberry Pi OS Bookworm. 

---------------------------------------------

**HDMI Audio script**

For some reason some HDMI dacs with built in aux port doesnt push audio through this port. I found a workaround that uses an EDID from a working DAC. This wont affect anything on the display. Its simple to install via ssh. This currently only applies it to the Primary hdmi port. I have not tried this with cloning the display feature in replayOS. If this does not enable your HDMI Audio, then get a new HDMI DAC that is known to work.

- SSH into ReplayOS with root/replayos credentials. How to ssh into ReplayOS is on the replayOS Wiki.
- [Go here](https://github.com/forkymcforkface/CRT-Custom/blob/main/replay/HDMI/enable_hdmidac_audio.sh)
- Press copy raw file as seen in this screenshot
<img width="458" height="330" alt="image" src="https://github.com/user-attachments/assets/de262502-a985-4ae0-9e96-b814ed35122b" />

- Paste into the terminal ssh window as seen in this screenshot
<img width="480" height="235" alt="image" src="https://github.com/user-attachments/assets/031c9c95-9594-4879-ba60-de2cf614c2cd" />

- Press enter:
- Rebbot Pi
