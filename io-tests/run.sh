#!/bin/bash
numRuns=5
mySize=16
fileName=data_
tempCopy=temp
sizeText='set $filesize='
inputText="bigfileset populated:"
outputText="IO Summary:"
runProg="/usr/local/bin/filebench -f"
declare -a testFiles=(
	"cloud_fileserver.f"
	"cloud_varmail.f"
	"cloud_webserver.f"
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
title="Run[#],TestType[test.f],Files[#],TotalSize[MB],TotalOps[#],Throughput[ops/s],Latency[ms/op]"
quickPrint $title $csvFile
for myTest in "${testFiles[@]}"
do
	#
	# run each filebench test numRuns specified times
	#
	for (( i=1; i<=$numRuns; i++ ))
	do
                #
                # ensure file size inside .f file is correct, then execute filebench
                #
                newText="$sizeText$mySize"
                newText+="k"
                sed --in-place "/$sizeText/c$newText" $myTest
		$runProg $myTest 1> $tempCopy 2> /dev/null

		#
		# parse output result data for key results
		#
		numFiles=$(sed "/$inputText/!d" $tempCopy | awk -F ' ' '{print $4}')
		totalSize=$(sed "/$inputText/!d" $tempCopy | awk -F ' ' '{print $18}')
		totalOps=$(sed "/$outputText/!d" $tempCopy | awk -F ' ' '{print $4}')
                throughPut=$(sed "/$outputText/!d" $tempCopy | awk -F ' ' '{print $6}')
		latency=$(sed "/$outputText/!d" $tempCopy | awk -F ' ' '{print $11}')

		#
		# output results to .raw + .csv + console
		#
		line="$i,$myTest,$numFiles,$totalSize,$totalOps,$throughPut,$latency"
		quickPrint $line $csvFile
		cat $tempCopy >> $rawFile
	done
done
rm -f $tempCopy
