
export NO_AT_BRIDGE=1

qemu-system-x86_64 \
-name level1 \
-m size=512M,slots=1,maxmem=1024M \
-boot order=c \
-drive file=/tmp/guest-imgs/diskRaw-60G.img,media=disk,format=raw,cache=writeback,aio=threads,if=virtio \
-cpu host,+vmx \
-smp cpus=8,cores=4,threads=2,sockets=1,maxcpus=8 \
-numa node,cpus=0-7 \
-enable-kvm \
-vga qxl \
-show-cursor \
-device virtio-net-pci,netdev=netLevel1 \
-netdev user,id=netLevel1 &

