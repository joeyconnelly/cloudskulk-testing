#!/bin/bash
insideVM=true
numRuns=5
#tag=_host
tag=_level1
#tag=_level2
fileName=LAST_
tempCopy=temp
errorLog=errFile.log
pathText='set $dir='
sizeText='set $filesize='
inputText="bigfileset populated:"
outputText="IO Summary:"
runProg="/usr/local/bin/filebench -f"
declare -a ranges=(
	"64k"
	"128k"	
	"8k"
	"128k"	
	"2k"
	"64k"	
)
declare -a testFiles=(
	"final_fileserver.f"
	"final_webserver.f"
	"final_varmail.f"
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
	if [ "$insideVM" = true ];then
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

#
# loop on each filebench macro
#
currRange=0
for myTest in "${testFiles[@]}"
do
	#
	# change home directory inside .f file
	#
	newPathText="$pathText$HOME/$dir"
	sed --in-place "/$pathText/c$newPathText" $myTest

	#
	# vary the min/max range of file sizes for current macro
	#
	for (( minMax=0; minMax<2; minMax++ ))
	do
	
		#
		# change file size inside .f file
		#
		newSizeText="$sizeText$newSize${ranges[$currRange]}"
		sed --in-place "/$sizeText/c$newSizeText" $myTest
		let currRange=$currRange+1

		#
		# loop single macro, same parameters to collect average
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
done

#
# clean unneeded files and save total script execution time
#
rm -f $tempCopy
endTime=$(date +"%m-%d-%Y_%H-%M-%S")
quickPrint $endTime $csvFile

