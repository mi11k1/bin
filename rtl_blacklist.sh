#!/bin/bash
sudo apt-get install cmake libusb-1.0-0-dev
sudo echo "blacklist dvb_usb_rtl28xxu" >> /etc/modprobe.d/blacklist.conf
sudo rmmod dvb_usb_rtl28xxu
git clone git://git.osmocom.org/rtl-sdr.git 
cd rtl-sdr
sudo cp rtl-sdr.rules /etc/udev/rules.d/
mkdir build
cd build
cmake ../
make
sudo make install
sudo ldconfig
