#!/bin/bash

enableDownload=false
numRuns=10
tag=host-avg
#tag=level1-avg-e1000
#tag=level2-avg
file="$tag-network-timing.data"
temp=net-trash.data
err=net-error.data
link="ftp://ftp.netperf.org/netperf/netperf-2.7.0.tar.gz"
version="netperf-2.7.0"
download=".tar.gz"
ops="-l 60"
test_addr="-H 127.0.0.1"

quickPrint(){
        echo -e "$1"
        echo -e "$1" >> $2
}

#
# Download benchmark
#
echo -e "---Script Start---"
repoDir=$(pwd)
echo -e $tag > $repoDir/$file
if [ ! -f /$HOME/$version$download -a "$enableDownload" = true ];then
	echo -e "Downloading benchmark now..."
	cd $HOME
#	wget $link
#	if [ $? -eq 0 ];then
#		echo -e "Download successfull.\nInstalling benchmark..."
#	else
		echo -e "Download issues...\nInstalling benchmark from backup..."
		cp $repoDir/$version$download $HOME
#	fi
	tar -xvzf $version$download
	cd $version
	./configure
	make
	sudo make install
	cd $repoDir
else
	echo -e "Benchmark installation found."
fi

#
# Run benchmark multiple times for average.
#
netserver 2>/dev/null
text="Run[#],RecvSockSize[B],SendSockSize[B],SendMsgSize[B],Throughput[MB/sec]"
quickPrint $text $repoDir/$file
for (( i=0; i<$numRuns; i++ ))
do
	netperf $test_addr $ops 1>$temp 2>$err

	recvSock=$(cat $temp | tail -n 1 | awk '{print $1}')
	sendSock=$(cat $temp | tail -n 1 | awk '{print $2}')
	sendMsg=$(cat $temp | tail -n 1 | awk '{print $3}')
	throughput=$(cat $temp | tail -n 1 | awk '{print $5}')
	text="$i,$recvSock,$sendSock,$sendMsg,$throughput"
	quickPrint $text $repoDir/$file
done

#
# Remove unneccesary files.
#
contents=$(du $err | awk '{print $1}')
if [ $contents -eq 0 ];then
	echo -e "No errors occured during testing."
	rm -f $err
fi
rm -f $temp
echo -e "---Script End---"

