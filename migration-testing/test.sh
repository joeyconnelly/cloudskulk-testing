#!/bin/bash

./img_create.sh

qemu-system-x86_64 -name migSource -m size=512M,slots=1,maxmem=1024M -boot order=c -drive file=/tmp/guest-imgs/diskRaw-60G.img,media=disk,format=raw,cache=writeback,aio=threads,if=virtio -machine type=pc-i440fx-2.3 -cpu Nehalem -enable-kvm -vga qxl -show-cursor -device virtio-net-pci,netdev=netSource -netdev user,id=netSource -monitor telnet:0:5555,server,nowait &

qemu-system-x86_64 -name mig-L1-Dest -m size=512M,slots=1,maxmem=1024M -boot order=c -drive file=/tmp/guest-imgs/copyRAW-60G.img,media=disk,format=raw,cache=writeback,aio=threads,if=virtio -machine type=pc-i440fx-2.3 -cpu Nehalem -enable-kvm -vga qxl -show-cursor -device virtio-net-pci,netdev=netL1Dest -netdev user,id=netL1Dest -incoming tcp:0:4446 &

exit -1
sleep 15

(
echo -e "info status"
echo -e "migrate -d tcp:0:4446"
echo -e "info migrate"
echo -e "info migrate"
sleep 60
echo -e "info migrate"
sleep 60
) | telnet 0 5555


