#!/bin/bash

disk=diskL1.raw
copy=copyDisk.raw

cd $HOME
rm -f $copy
qemu-img create -f raw $copy 60G

qemu-system-x86_64 -name migration-Source -m size=1G,slots=1,maxmem=2G -boot order=c -drive file=$disk,media=disk,index=0,media=disk,format=raw,cache=none,if=virtio -machine type=pc-i440fx-2.3 -cpu Nehalem,+vmx -enable-kvm -vga std -show-cursor -device virtio-net-pci,netdev=netSource -netdev user,id=netSource -monitor telnet:0:5555,server,nowait &

qemu-system-x86_64 -name migration-Destination -m size=1G,slots=1,maxmem=2G -boot order=c -drive file=$copy,media=disk,index=0,media=disk,format=raw,cache=none,if=virtio -machine type=pc-i440fx-2.3 -cpu Nehalem,+vmx -enable-kvm -vga std -show-cursor -device virtio-net-pci,netdev=netDest -netdev user,id=netDest -incoming tcp:0:4446 &

exit -1

(
echo -e "info status"
echo -e "migrate -d tcp:0:4446"
echo -e "info migrate"
echo -e "info migrate"
sleep 60
echo -e "info migrate"
sleep 60
) | telnet 0 5555


