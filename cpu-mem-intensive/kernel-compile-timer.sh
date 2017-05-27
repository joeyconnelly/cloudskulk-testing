#!/bin/bash

numRuns=3
testTag="kernel compile data in level1 120G"
tag=level1-gold
link="https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.0.tar.xz"
file="$tag-build.data"
version="linux-4.0"
download=".tar.xz"
firstRun=false

#
# Initial files and script directory location.
#
repoDir=$(pwd)
echo -e $headerTag > $repoDir/$file
echo -e $tag >> $repoDir/$file

#
# Download kernel version if not found.
#
cd $HOME
if [ ! -f $version$download ];then
	wget $link
fi
rm -rf $version
tar -xvf $version$download

#
# Use the same host config file for all.
#
cd $version
if [ "$firstRun" = true ];then
	make menuconfig
	cp .config $repoDir
else
	cp $repoDir/.config .
fi

#
# Compile the kernel + save build times.
#
for (( i=0; i<$numRuns; i++ ))
do
	make clean

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
done

