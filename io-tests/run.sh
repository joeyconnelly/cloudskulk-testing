#!/bin/bash
numRuns=5
fileName=data_
tempCopy=temp
inputText="bigfileset populated:"
outputText="IO Summary:"
runProg="/usr/local/bin/filebench -f"
declare -a testFiles=(
	"fileserver.f"
	"varmail.f"
	"webserver.f"
)
quickPrint(){
	echo -e "$1"
	echo -e "$1" >> $2
}


#
# run each filebench pre-built macro test
#
currTime=$(date +"%m-%d-%Y_%H-%M-%S")
rawFile=$fileName$currTime.raw
csvFile=$fileName$currTime.csv
title="Run[#],TestType[test.f],Files[#],TotalSize[MB],Throughput[ops/s],Latency[ms]"
quickPrint $title $csvFile
for myTest in "${testFiles[@]}"
do
	#
	# run each filebench test numRuns specified times
	#
	for (( i=1; i<=$numRuns; i++ ))
	do
		$runProg $myTest 1> $tempCopy 2> /dev/null

		#
		# parse output result data for key results
		#
		numFiles=$(sed "/$inputText/!d" $tempCopy | awk -F ' ' '{print $4}')
		totalSize=$(sed "/$inputText/!d" $tempCopy | awk -F ' ' '{print $18}')
		throughPut=$(sed "/$outputText/!d" $tempCopy | awk -F ' ' '{print $10}')
		latency=$(sed "/$outputText/!d" $tempCopy | awk -F ' ' '{print $11}')

		#
		# output results to .raw + .csv + console
		#
		line="$i,$myTest,$numFiles,$totalSize,$throughPut,$latency"
		quickPrint $line $csvFile
		cat $tempCopy >> $rawFile
	done
done
rm -f $tempCopy
