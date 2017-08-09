#!/bin/bash

#
# Adjustable script parameters.
#
TAG=_L0
FILE_NAME=KERNEL_raw60G_1to2G_virtio-disk_cache-none_cpu8_virtio-net_cfq
NUM_RUNS=3
FIRST_RUN=true
LINK="https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.0.tar.xz"
SUFFIX=".tar.xz"
TEST_DIR=$HOME
RESULTS_DIR=$(pwd)
CODE_BASE=$(echo $LINK | awk -F "/" '{print $NF}' | sed -e "s/$SUFFIX//")
DOWNLOAD=$CODE_BASE$SUFFIX
LOG=_errFile.log

quickPrint(){
        echo -e "$1"
        echo -e "$1" >> $2
}

#
# Create initial output data file.
#
tagTime=$(date +"%m-%d")
rawFile="$RESULTS_DIR/$FILE_NAME$tagTime$TAG.data"
errFile="$RESULTS_DIR/$tagTime$LOG"
startTime=$(date +"%m-%d-%Y_%H-%M-%S")
title="Run[#],startDecomp,endDecomp,totalDecomp,startComp,endComp,totalComp"
rm -f $errFile
quickPrint $startTime $rawFile
quickPrint $title $rawFile

#
# Download linux kernel in testing directory.
#
if [ ! -d $TEST_DIR ];then
        mkdir $TEST_DIR
fi
cd $TEST_DIR
if [ ! -f $DOWNLOAD ];then
        wget $LINK
fi

#
# Loop using same config file to collect average.
#
for (( i=0; i<$NUM_RUNS; i++ ))
do
        #
        # Exit early if initial data is bogus (for testing convience).
        #
        if [ $i = 1 ];then
                echo "Do you want to continue (y|n): "
                read input_variable
                if [ "$input_variable" == "n" ];then
                        rm -f $DOWNLOAD
                        rm -rf $CODE_BASE
                        exit -1
                fi
        fi

        #
        # Make sure each run starts w/o decompressed or compiled kernel.
        #
        rm -rf $CODE_BASE

        #
        # Execute kernel decompression.
        #
        startDecompress=$(date +%s.%N)
        tar -xvf $DOWNLOAD 2> $errFile
        endDecompress=$(date +%s.%N)
        totalDecompress=$(python -c "print(${endDecompress} - ${startDecompress})")
        dconsole="\n\n\nDecompressRun[$i],$startDecompress,$endDecompress,$totalDecompress\n\n\n"
        quickPrint $dconsole /dev/null

        #
        # Create/use common config file for all tests.
        #
        cd $CODE_BASE
        if [ $FIRST_RUN == true ] && [ $i -eq 0 ];then
                make menuconfig
                cp .config $RESULTS_DIR
        else
                cp -f $RESULTS_DIR/.config .
        fi

        #
        # Execute kernel compile.
        #
        make clean
        numCPUs="-j$(nproc)"
        startCompile=$(date +%s.%N)
        make $numCPUs 2> $errFile
        endCompile=$(date +%s.%N)
        totalCompile=$(python -c "print(${endCompile} - ${startCompile})")
        cconsole="\n\n\nCompileRun[$i],$startCompile,$endCompile,$totalCompile\n\n\n"
        quickPrint $cconsole /dev/null

        #
        # Print both decompression and compile results to file.
        #
        rtitle="Run[$i],$startDecompress,$endDecompress,$totalDecompress,$startCompile,$endCompile,$totalCompile"
        quickPrint $rtitle $rawFile
        cd $TEST_DIR
done

#
# Clean unneeded files and save total script execution time for user convience.
#
rm -f $DOWNLOAD
rm -rf $CODE_BASE
endTime=$(date +"%m-%d-%Y_%H-%M-%S")
quickPrint $endTime $rawFile

