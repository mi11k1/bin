#!/bin/bash
#xterm -e "sudo netdiscover -i wlan0 -r 10.10.1.0/24"
xterm -T NETDISCOVER -e 'sudo netdiscover -r 192.168.1.0/24'
