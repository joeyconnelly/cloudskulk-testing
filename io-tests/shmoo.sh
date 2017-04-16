#!/bin/bash
min=1
max=9500
base=250
fileName=dataShmoo_
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
	testID=0

	#
	# iterate each filebench test increasing file sizes by given base
	#
	for (( newSize=$min; newSize<=$max; newSize+=$base ))
	#for (( newSize=$min; newSize<=$max; newSize*=$base ))
	do
		#
		# change file size inside .f file, then execute filebench
		#	
		newText="$sizeText$newSize"
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
		line="$testID,$myTest,$numFiles,$totalSize,$totalOps,$throughPut,$latency"
		quickPrint $line $csvFile
		cat $tempCopy >> $rawFile
		let testID++
	done
done
rm -f $tempCopy
