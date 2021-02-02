#!/bin/bash

sudo apt install gnupg2 curl -y
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list
sudo apt update
sudo apt dist-upgrade -y
sudo apt install syncthing -y
