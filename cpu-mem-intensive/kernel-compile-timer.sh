#!/bin/bash

#tag=host
#tag=level1
tag=level2
link="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.11.1.tar.xz"
file="$tag-compile-timing.data"
version="linux-4.11.1"
download=".tar.xz"


repoDir=$(pwd)
cd $HOME
echo -e $tag > $repoDir/$file
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
echo -e "Start_Time(seconds),$startTime" >> $repoDir/$file
echo -e "End_Time(seconds),$endTime"
echo -e "End_Time(seconds),$endTime" >> $repoDir/$file
echo -e "Elapsed_Time(seconds),$elapsedTime"
echo -e "Elapsed_Time(seconds),$elapsedTime" >> $repoDir/$file

