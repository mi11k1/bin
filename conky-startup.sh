#!/bin/bash
sleep 20s
killall conky
cd "/home/mi11k1/.config/mx-conky-data/MX-KoO/"
conky -c "/home/mi11k1/.config/mx-conky-data/MX-KoO/MX-Full" &
exit 0
