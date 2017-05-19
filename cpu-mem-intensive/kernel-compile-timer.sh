#!/bin/bash

numRuns=4
#tag=host-avg
#tag=level1-avg
tag=level2-avg
link="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.11.1.tar.xz"
file="$tag-compile-timing.data"
version="linux-4.11.1"
download=".tar.xz"

#
# Download kernel version.
#
repoDir=$(pwd)
echo -e $tag > $repoDir/$file
cd $HOME
wget $link

#
# Compile the kernel + save build times.
#
for (( i=0; i<$numRuns; i++ ))
do
	tar -xvf $version$download
	cd $version
	make defconfig

	startTime=$(date +%s.%N)
	make -j4 
	endTime=$(date +%s.%N)

	elapsedTime=$(python -c "print(${endTime} - ${startTime})")
	echo -e "Run[$i],Start_Time(seconds),$startTime"
	echo -e "Run[$i],Start_Time(seconds),$startTime" >> $repoDir/$file
	echo -e "Run[$i],End_Time(seconds),$endTime"
	echo -e "Run[$i],End_Time(seconds),$endTime" >> $repoDir/$file
	echo -e "Run[$i],Elapsed_Time(seconds),$elapsedTime"
	echo -e "Run[$i],Elapsed_Time(seconds),$elapsedTime" >> $repoDir/$file
	
	cd $HOME
	rm -rf $version
done

