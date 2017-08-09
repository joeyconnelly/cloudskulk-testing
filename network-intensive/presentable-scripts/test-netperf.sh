#!/bin/bash

# Adjustable script parameters.
#
TAG=_L0
FILE_NAME=NETPERF_raw60G_1to2G_virtio-disk_cache-none_cpu8_virtio-net_cfq
NUM_RUNS=5
LINK="ftp://ftp.netperf.org/netperf/netperf-2.7.0.tar.gz"
SUFFIX=".tar.gz"
TEST_DIR=$HOME
RESULTS_DIR=$(pwd)
CODE_BASE=$(echo $LINK | awk -F "/" '{print $NF}' | sed -e "s/$SUFFIX//")
DOWNLOAD=$CODE_BASE$SUFFIX
COPY=temp
LOG=_errFile.log

#
# Non-adjustable parameters.
#
OPTS="-l 60"
TEST_ADDR="-H 127.0.0.1"

quickPrint(){
    echo -e "$1"
    echo -e "$1" >> $2
}

#
# Create initial output data files.
#
tagTime=$(date +"%m-%d")
rawFile="$RESULTS_DIR/$FILE_NAME$tagTime$TAG.data"
errFile="$RESULTS_DIR/$tagTime$LOG"
startTime=$(date +"%m-%d-%Y_%H-%M-%S")
title="Run[#],RecvSockSize[B],SendSockSize[B],SendMsgSize[B],Throughput[MB/sec]"
rm -f $errFile
quickPrint $startTime $rawFile
quickPrint $title $rawFile

#
# Download netperf source code in testing directory.
#
if [ ! -d $TEST_DIR ];then
    mkdir $TEST_DIR
fi
cd $TEST_DIR
if [ ! -f $DOWNLOAD ];then
    wget $LINK
    if [ $? -ne 0 ];then
        quickPrint "Error: Download issues..." $errFile
        if [ ! -e "$RESULTS_DIR/$DOWNLOAD" ];then
            quickPrint "Error: Backup download does not exist..." $errFile
            exit -1
        fi
        cp -f $RESULTS_DIR/$DOWNLOAD $TEST_DIR
    fi
	
    #
    # Unzip, configure, and compile source code.
    #
    tar -xvzf $DOWNLOAD
    cd $CODE_BASE
    ./configure
    make
    sudo make install
    cd $RESULTS_DIR
fi

#
# Loop with same parameters to collect average.
#
netserver 2>/dev/null
for (( i=0; i<$NUM_RUNS; i++ ))
do
    #
    # Execute filebench benchmark.
    #
    netperf $TEST_ADDR $OPTS 1>$COPY 2>$errFile

    #
    # Parse output result data for key results.
    #
    recvSock=$(cat $COPY | tail -n 1 | awk '{print $1}')
    sendSock=$(cat $COPY | tail -n 1 | awk '{print $2}')
    sendMsg=$(cat $COPY | tail -n 1 | awk '{print $3}')
    throughput=$(cat $COPY | tail -n 1 | awk '{print $5}')
	
    #
    # Output results to .data + console.
    #
    results="$i,$recvSock,$sendSock,$sendMsg,$throughput"
    quickPrint $results $rawFile
done

#
# Remove unneccesary files.
#
contents=$(du $errFile | awk '{print $1}')
if [ $contents -eq 0 ];then
    quickPrint "\n\n\nNo errors occured during testing.\n\n\n" /dev/null
    rm -f $errFile
fi
rm -f $COPY

