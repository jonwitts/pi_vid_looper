#!/bin/bash

# Setup script to install our required software and 
# configure services etc.

# Make sure script is run as root.
if [ "$(id -u)" != "0" ]; then
  echo "Must be run as root with sudo! Try: sudo ./setup.sh"
  exit 1
fi

# update and upgrade existing packages
echo "Upgrading existing packages"
echo "=========================="
apt-get update && apt-get dist-upgrade -y

# install our required packages
echo "Installing dependencies..."
echo "=========================="
apt-get install git wget omxplayer util-linux pmount python3 python3-gpiozero exfat-fuse exfat-utils -y

# copy our bash script
echo "Install our piVidLooper script..."
echo "=========================="
mkdir /piVidLooper
cd /piVidLooper
wget -N https://raw.githubusercontent.com/jonwitts/pi_vid_looper/master/piVidLooper.sh
chmod +x ./piVidLooper.sh

# copy our shutdown Python script
echo "Install our Python shutdown script..."
echo "=========================="
wget -N https://raw.githubusercontent.com/jonwitts/pi_vid_looper/master/pythonShutdown.py
chmod +x ./pythonShutdown.py

# copy and activate our systemd definitions
echo "Copy and activate our systemd definitions..."
echo "=========================="
# piVidLooper service
wget -N https://raw.githubusercontent.com/jonwitts/pi_vid_looper/master/piVidLooper.service
mv ./piVidLooper.service /lib/systemd/system/piVidLooper.service
chmod 644 /lib/systemd/system/piVidLooper.service

# pythonShutdown service
wget -N https://raw.githubusercontent.com/jonwitts/pi_vid_looper/master/pythonShutdown.service
mv ./pythonShutdown.service /lib/systemd/system/pythonShutdown.service
chmod 644 /lib/systemd/system/pythonShutdown.service

# reload and enable
systemctl daemon-reload
systemctl enable piVidLooper.service
systemctl enable pythonShutdown.service

# hide our user prompt and clear the screen at start up
#echo 'PS1=""' >> /home/pi/.bashrc
#echo "setterm --cursor off" >> /home/pi/.bashrc
#echo "clear" >> /home/pi/.bashrc

# up our GPU RAM
echo "gpu_mem=512" >> /boot/config.txt

# done
echo "Done. Rebooting now"
echo "=========================="
reboot
