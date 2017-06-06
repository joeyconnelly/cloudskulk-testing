#!/bin/bash
numRuns=5
tag=_L2_justVarMail
min=1
max=128
base=2
fileName=goldSHMOO_
tempCopy=temp
errorLog=errFile.log
sizeText='set $filesize='
pathText='set $dir='
inputText="bigfileset populated:"
outputText="IO Summary:"
runProg="/usr/local/bin/filebench -f"
declare -a testFiles=(
	"adjust_varmail.f"
#	"adjust_webserver.f"
#	"adjust_fileserver.f"
)
dir=testing
declare -a benchFiles=(
	"$HOME/$dir/bigfileset"
	"$HOME/$dir/logfiles"
)
quickPrint(){
	echo -e "$1"
	echo -e "$1" >> $2
}
removeFiles(){
	rm -rf ${benchFiles[0]} ${benchFiles[1]}
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
	testID=0

	#
	# iterate each filebench test increasing file sizes by given base
	#
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
		let testID++
	done
done

#
# clean unneeded files and save total script execution time
#
rm -f $tempCopy
endTime=$(date +"%m-%d-%Y_%H-%M-%S")
quickPrint $endTime $csvFile

