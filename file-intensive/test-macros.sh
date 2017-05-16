#!/bin/bash
insideVM=1
numRuns=1
#tag=_host_cfq_homeDir
tag=_level1_cfq_raw_60G_virtio-net_2to4G_threads_none
fileName=data_
tempCopy=temp
errorLog=errFile.log
pathText='set $dir='
inputText="bigfileset populated:"
outputText="IO Summary:"
runProg="/usr/local/bin/filebench -f"
declare -a testFiles=(
	"my_fileserver.f"
	"my_webserver.f"
	"my_varmail.f"
)
dir=testing
declare -a benchFiles=(
	"$HOME/$dir/bigfileset"
	"$HOME/$dir/logfiles"
	"/tmp/filebench-shm*"
)
quickPrint(){
	echo -e "$1"
	echo -e "$1" >> $2
}
removeFiles(){
	rm -rf ${benchFiles[0]} ${benchFiles[1]}
	if [ $insideVM -eq 1 ];then
		rm -f ${benchFiles[2]}
	fi
}

#
# create filebench directories and initial output data files
#
rm -rf $HOME/$dir
mkdir $HOME/$dir
tagTime=$(date +"%m-%d")
rawFile=$fileName$tagTime$tag.raw
csvFile=$fileName$tagTime$tag.csv
startTime=$(date +"%m-%d-%Y_%H-%M-%S")
title="Run[#],TestType[test.f],Files[#],TotalSize[MB],TotalOps[#],Throughput[ops/s],Latency[ms/op]"
rm -f $errorLog
echo -e "$startTime" > $errorLog
quickPrint $startTime $csvFile
quickPrint $title $csvFile
removeFiles
for myTest in "${testFiles[@]}"
do
	#
	# change home directory inside .f file
	#
	newText="$pathText$HOME/$dir"
	sed --in-place "/$pathText/c$newText" $myTest

	#
	# loop filebench w/identical parameters to collect average
	#
	for (( testID=0; testID<$numRuns; testID++ ))
	do
		#
		# execute filebench benchmark
		#
		removeFiles
		currTime=$(date +"%H-%M-%S")
		echo -e "time before test: $currTime"
		$runProg $myTest 1> $tempCopy 2>> $errorLog
		currTime=$(date +"%H-%M-%S")
		echo -e "time after test: $currTime"
		removeFiles
		df -h

		#
		# parse output result data for key results
		#
		numFiles=$(sed "/$inputText/!d" $tempCopy | awk -F ' ' '{print $4}')
		totalSize=$(sed "/$inputText/!d" $tempCopy | awk -F ' ' '{print $18}')
		totalOps=$(sed "/$outputText/!d" $tempCopy | awk -F ' ' '{print $4}')
		throughPut=$(sed "/$outputText/!d" $tempCopy | awk -F ' ' '{print $6}')
		latency=$(sed "/$outputText/!d" $tempCopy | awk -F ' ' '{print $11}' | awk -F "ms/op" '{print $1}')

		#
		# output results to .raw + .csv + console
		#
		line="$testID,$myTest,$numFiles,$totalSize,$totalOps,$throughPut,$latency"
		quickPrint $line $csvFile
		removeFiles
		cat $tempCopy >> $rawFile
	done
done

#
# clean unneeded files and save total script execution time
#
rm -f $tempCopy
endTime=$(date +"%m-%d-%Y_%H-%M-%S")
quickPrint $endTime $csvFile

