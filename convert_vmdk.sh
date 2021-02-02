#!/bin/bash
for i in *.vmdk; do qemu-img convert -f vmdk $i -O raw $i.raw; done
cat *.raw > tmpImage.raw
qemu-img convert tmpImage.raw finalImage.qcow2
rm *.raw
