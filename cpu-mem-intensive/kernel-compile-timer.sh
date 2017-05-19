#!/bin/bash

tag=host
link="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.11.1.tar.xz"
file="$tag-compile-timing.data"
version="linux-4.11.1"
download=".tar.xz"


repoDir=$(pwd)
cd $HOME
echo -e $tag > $file
wget $link
tar -xvf $version$download
cd $version
#myKern=$(uname --kernel-release)
#cp /boot/config-$myKern .config
make defconfig


startTime=$(date +%s.%N)
make -j4 
endTime=$(date +%s.%N)


elapsedTime=$(python -c "print(${endTime} - ${startTime})")
echo -e "Start_Time(seconds),$startTime"
echo -e "Start_Time(seconds),$startTime" >> $file
echo -e "End_Time(seconds),$endTime"
echo -e "End_Time(seconds),$endTime" >> $file
echo -e "Elapsed_Time(seconds),$elapsedTime"
echo -e "Elapsed_Time(seconds),$elapsedTime" >> $file
cd $HOME
mv $file $repoDir

