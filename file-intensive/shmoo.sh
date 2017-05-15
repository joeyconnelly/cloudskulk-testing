#!/bin/bash
numRuns=1
tag=_2to4g_60gqcow_virtio_writeback_threads_homeDir
min=1
max=128
# nfiles=50000, filesize_max=128k, totalSize=>6.4G
base=2
fileName=newShmoo_
tempCopy=temp
errorLog=errFile.log
sizeText='set $filesize='
pathText='set $dir='
inputText="bigfileset populated:"
outputText="IO Summary:"
runProg="/usr/local/bin/filebench -f"
declare -a testFiles=(
	"adjustAPPEND_16_fileserver.f"
	"adjustNOAPPEND_fileserver.f"
	"adjustAPPEND_16_webserver.f"
	"adjustNOAPPEND_webserver.f"
	"adjustAPPEND_16_varmail.f"
	"adjustNOAPPEND_varmail.f"
)
declare -a benchFiles=(
	"$HOME/testing/bigfileset"
	"$HOME/testing/logfiles"
	"/tmp/filebench-shm*"
)
quickPrint(){
	echo -e "$1"
	echo -e "$1" >> $2
}
removeFiles(){
	sudo rm -rf ${benchFiles[0]} ${benchFiles[1]}
	sudo rm -f ${benchFiles[2]}
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
	removeFiles
	for (( newSize=$min; newSize<=$max; newSize*=$base ))
	do
		#
		# change file size + home directory inside .f file
		#	
		removeFiles
		newText="$sizeText$newSize"
		newText+="k"
		sed --in-place "/$sizeText/c$newText" $myTest
		newText="$pathText$HOME"
		newText+="/testing"
		sed --in-place "/$pathText/c$newText" $myTest

		#
		# loop filebench w/identical parameters to collect average
		#
		for (( i=0; i<$numRuns; i++ ))
		do
			#
			# execute filebench benchmark
			#
			removeFiles
			$runProg $myTest 1> $tempCopy 2>> $errorLog
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
		let testID++
	done
done
rm -f $tempCopy
