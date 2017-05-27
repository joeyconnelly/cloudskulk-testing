#!/bin/bash

numRuns=3
testTag="blah"
tag=gold
#link="https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-4.11.1.tar.xz"
link="https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.0.tar.xz"
file="$tag-compile-timing.data"
version="linux-4.0"
download=".tar.xz"

repoDir=$(pwd)
echo -e $testTag > $repoDir/$file
echo -e $tag >> $repoDir/$file
#for (( i=0; i<$numRuns; i++ ))
#do
	cd $HOME
	wget $link
#	rm -rf $version
	tar -xvf $version$download
	cd $version
#	make defconfig &>/dev/null

	make menuconfig

#	make clean
	echo -e "Run[$i]..."
	startTime=$(date +%s.%N)
	make -j8
	endTime=$(date +%s.%N)

	elapsedTime=$(python -c "print(${endTime} - ${startTime})")
	echo -e "Run[$i],Start_Time(seconds),$startTime"
	echo -e "Run[$i],Start_Time(seconds),$startTime" >> $repoDir/$file
	echo -e "Run[$i],End_Time(seconds),$endTime"
	echo -e "Run[$i],End_Time(seconds),$endTime" >> $repoDir/$file
	echo -e "Run[$i],Elapsed_Time(seconds),$elapsedTime"
	echo -e "Run[$i],Elapsed_Time(seconds),$elapsedTime" >> $repoDir/$file
#done

