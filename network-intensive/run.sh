#!/bin/bash

numRuns=1
#tag=host
tag=level1
#tag=level2
link="ftp://ftp.netperf.org/netperf/netperf-2.7.0.tar.gz"
file="$tag-network-timing.data"
version="netperf-2.7.0"
download=".tar.gz"

#
# Download netperf version.
#
repoDir=$(pwd)
echo -e $tag > $repoDir/$file
cd $HOME
wget $link
tar -xvzf $version$download
cd $version
./configure
make
sudo make install

#
# Run netperf + save execution times.
#
for (( i=0; i<$numRuns; i++ ))
do
echo -e "Running netpeft..."
#        startTime=$(date +%s.%N)
#        make -j4
#        endTime=$(date +%s.%N)
#
#        elapsedTime=$(python -c "print(${endTime} - ${startTime})")
#        echo -e "Run[$i],Start_Time(seconds),$startTime"
#        echo -e "Run[$i],Start_Time(seconds),$startTime" >> $repoDir/$file
#        echo -e "Run[$i],End_Time(seconds),$endTime"
#        echo -e "Run[$i],End_Time(seconds),$endTime" >> $repoDir/$file
#        echo -e "Run[$i],Elapsed_Time(seconds),$elapsedTime"
#        echo -e "Run[$i],Elapsed_Time(seconds),$elapsedTime" >> $repoDir/$file
done

