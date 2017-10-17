#!/bin/bash

sudo ./usb-downloader -t nxp4330 -b bl1-usbboot.bin -a 0xffff0000 -j 0xffff0000
sleep 3
sudo ./usb-downloader -t nxp4330 -f fip-loader-usb.img -a 0x63c00000 -j 0x63c00000
