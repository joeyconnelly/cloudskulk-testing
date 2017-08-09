#!/bin/bash

# Adjustable script parameters.
#
TAG=_L0
FILE_NAME=FILEBENCH_raw60G_1to2G_virtio-disk_cache-none_cpu8_virtio-net_cfq
NUM_RUNS=5
SHMOO_FILE_SIZE=false
MIN=1
MAX=128
BASE=2
EXE="/usr/local/bin/filebench -f"
declare -a TEST_FILES=(
    "cloudskulk-fileserver.f"
    "cloudskulk-webserver.f"
    "cloudskulk-varmail.f"
)
TEST_DIR=filebench-tempfiles
COPY=temp
LOG=_errFile.log

#
# Non-adjustable parameters.
#
PATH_TXT='set $dir='
SIZE_TXT='set $filesize='
INPUT_TXT="bigfileset populated:"
OUTPUT_TXT="IO Summary:"
# IO testing file system on HOME path.
declare -a BENCH_FILES=(
    "$HOME/$TEST_DIR/bigfileset"
    "$HOME/$TEST_DIR/logfiles"
)
if [ $SHMOO_FILE_SIZE == false ];then
    MIN=1
    MAX=2
fi

quickPrint(){
    echo -e "$1"
    echo -e "$1" >> $2
}
removeFiles(){
    # Not removing these potentially large files from file system
    #  was found to cause performance degradation in subsequent tests.
    rm -rf ${BENCH_FILES[0]} ${BENCH_FILES[1]}
}

#
# Create initial output data files/directories.
#
rm -rf $HOME/$TEST_DIR
mkdir $HOME/$TEST_DIR
tagTime=$(date +"%m-%d")
rawFile=$FILE_NAME$tagTime$TAG.raw
csvFile=$FILE_NAME$tagTime$TAG.csv
errFile=$tagTime$LOG
startTime=$(date +"%m-%d-%Y_%H-%M-%S")
title="Run[#],TestType[test.f],Files[#],TotalSize[MB],TotalOps[#],
   Throughput[ops/s],Latency[ms/op]"
rm -f $errFile
quickPrint $startTime $csvFile
quickPrint $title $csvFile

#
# Loop on each filebench macro.
#
for currTest in "${TEST_FILES[@]}"
do
    #
    # Change home directory inside .f file.
    #
    newPathText="$PATH_TXT$HOME/$TEST_DIR"
    sed --in-place "/$PATH_TXT/c$newPathText" $currTest

    #
    # Iterate each filebench test increasing file sizes by given base.
    #
    for (( newSize=$MIN; newSize<=$MAX; newSize*=$BASE ))
    do

        #
        # Change file size inside .f file.
        #
        if [ $SHMOO_FILE_SIZE == true ];then
            newSizeText="$SIZE_TXT$newSize"
            newSizeText+="k"
            sed --in-place "/$SIZE_TXT/c$newSizeText" $currTest
        else
            let newSize=$MAX+1
        fi

        #
        # Loop single macro, same parameters to collect average.
        #
        for (( testID=0; testID<$NUM_RUNS; testID++ ))
        do

            #
            # Execute filebench benchmark.
            #
            removeFiles
            currTime=$(date +"%H-%M-%S")
            echo -e "testing convience, time before test: $currTime"
            $EXE $currTest 1> $COPY 2>> $errFile
            currTime=$(date +"%H-%M-%S")
            echo -e "testing convience, time after test: $currTime"
            removeFiles
            ### for memory info while testing issue: df -h

            #
            # Parse output result data for key results.
            #
            numFiles=$(sed "/$INPUT_TXT/!d" $COPY | awk -F ' ' '{print $4}')
            totalSize=$(sed "/$INPUT_TXT/!d" $COPY | awk -F ' ' '{print $18}')
            totalOps=$(sed "/$OUTPUT_TXT/!d" $COPY | awk -F ' ' '{print $4}')
            throughPut=$(sed "/$OUTPUT_TXT/!d" $COPY | awk -F ' ' '{print $6}')
            latency=$(sed "/$OUTPUT_TXT/!d" $COPY | awk -F ' ' '{print $11}' | 
               awk -F "ms/op" '{print $1}')

            #
            # Output results to .raw + .csv + console.
            #
            line="$testID,$currTest,$numFiles,$totalSize,$totalOps,
               $throughPut,$latency"
            quickPrint $line $csvFile
            cat $COPY >> $rawFile
        done
    done
done

#
# Clean unneeded files and save total script execution time for user convenience.
#
rm -f $COPY
endTime=$(date +"%m-%d-%Y_%H-%M-%S")
quickPrint $endTime $csvFile

