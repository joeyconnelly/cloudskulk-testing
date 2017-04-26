#!/bin/bash
numRuns=1
tag=_level1-none-12G
min=1
max=128
base=2
fileName=shmooData_
tempCopy=temp
errorLog=errFile.log
sizeText='set $filesize='
inputText="bigfileset populated:"
outputText="IO Summary:"
runProg="/usr/local/bin/filebench -f"
declare -a testFiles=(
	"def_fileserver.f"
	"def_varmail.f"
	"def_webserver.f"
)
quickPrint(){
	echo -e "$1"
	echo -e "$1" >> $2
}


#
# run filebench macros
#
currTime=$(date +"%m-%d")
rawFile=$fileName$currTime$tag.raw
csvFile=$fileName$currTime$tag.csv
title="Run[#],TestType[test.f],Files[#],TotalSize[MB],TotalOps[#],Throughput[ops/s],Latency[ms/op]"
quickPrint $currTime $errorLog
quickPrint $title $csvFile
#testID=0
for myTest in "${testFiles[@]}"
do
	#
	# iterate each filebench test increasing file sizes by given base
	#
	testID=0
	for (( newSize=$min; newSize<=$max; newSize*=$base ))
	do
		#
		# change file size inside .f file
		#	
		newText="$sizeText$newSize"
		newText+="k"
		sed --in-place "/$sizeText/c$newText" $myTest

		#
		# loop filebench w/identical parameters to collect average
		#
		for (( i=0; i<$numRuns; i++ ))
		do
			#
			# execute filebench benchmark
			#
			$runProg $myTest 1> $tempCopy 2>> $errorLog

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
			cat $tempCopy >> $rawFile

		done
		let testID++
	done
done
rm -f $tempCopy
