#!/bin/bash

# Setup script to install our required software and 
# configure services etc.

# Make sure script is run as root.
if [ "$(id -u)" != "0" ]; then
  echo "Must be run as root with sudo! Try: sudo ./setup.sh"
  exit 1
fi

# update the sources.list file
echo "Updating APT sources"
echo "=========================="
# comment out old repo
sed -i.old -e 's|deb http://raspbian|# deb http://raspbian|g' /etc/apt/sources.list
# add new repo to end of file
sed -i.old2 -e "\$adeb http://legacy.raspbian.org/raspbian/ buster main contrib non-free rpi" /etc/apt/sources.list

# update and upgrade existing packages
echo "Upgrading existing packages"
echo "=========================="
apt update && apt dist-upgrade -y && apt autoremove -y

# install our required packages
echo "Installing dependencies..."
echo "=========================="
apt-get install git wget omxplayer util-linux python3 python3-gpiozero python3-pip exfat-fuse exfat-utils -y

# copy our bash script
echo "Install our piVidLooper script..."
echo "=========================="
mkdir /piVidLooper
cd /piVidLooper
wget -N https://raw.githubusercontent.com/jonwitts/pi_vid_looper/refs/heads/master/piVidLooper.sh
chmod +x ./piVidLooper.sh

# copy our shutdown Python script
echo "Install our Python shutdown script..."
echo "=========================="
wget -N https://raw.githubusercontent.com/jonwitts/pi_vid_looper/refs/heads/master/pythonShutdown.py
chmod +x ./pythonShutdown.py

# copy and activate our systemd definitions
echo "Copy and activate our systemd definitions..."
echo "=========================="
# piVidLooper service
wget -N https://raw.githubusercontent.com/jonwitts/pi_vid_looper/refs/heads/master/piVidLooper.service
mv ./piVidLooper.service /lib/systemd/system/piVidLooper.service
chmod 644 /lib/systemd/system/piVidLooper.service

# pythonShutdown service
wget -N https://raw.githubusercontent.com/jonwitts/pi_vid_looper/refs/heads/master/pythonShutdown.service
mv ./pythonShutdown.service /lib/systemd/system/pythonShutdown.service
chmod 644 /lib/systemd/system/pythonShutdown.service

# reload and enable
systemctl daemon-reload
systemctl enable piVidLooper.service
systemctl enable pythonShutdown.service

# Install and configure the Pimoroni Fan Shim
cd /
git clone https://github.com/pimoroni/fanshim-python
cd fanshim-python
./install.sh
cd examples
sudo ./install-service.sh --on-threshold 65 --off-threshold 55 --delay 2

# up our GPU RAM
echo "" >> /boot/config.txt
echo "# increase gpu memory for devices with over 1024 RAM" >> /boot/config.txt
echo "gpu_mem_1024=512" >> /boot/config.txt

# set up screen blanking at boot
# send console logs to tty3
sed -i.old -e 's|console=tty1|console=tty3|g' /boot/cmdline.txt
# log errors only and change font to black
sed -i.old2 -e 's|$| loglevel=1  vt.color=0x00|g' /boot/cmdline.txt

# done
echo "Done. Rebooting now"
echo "=========================="
reboot
