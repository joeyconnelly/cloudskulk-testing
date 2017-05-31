#!/bin/bash

numRuns=5
tag=new-level1-60G-raw-sda6
link="https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.0.tar.xz"
file="$tag-build.data"
version="linux-4.0"
download=".tar.xz"
firstRun=false

repoDir=$(pwd)
echo -e $tag > $repoDir/$file
echo -e "Run[#],startDecomp,endDecomp,totalDecomp,startComp,endComp,totalComp" >> $repoDir/$file

if [ ! -d $dir ];then
	sudo mkdir $dir
fi
cd $dir
if [ ! -f $version$download ];then
	wget $link
fi

for (( i=0; i<$numRuns; i++ ))
do
	if [ $i = 1 ];then
		echo "Do you want to continue (y|n): "
		read input_variable
		if [ "$input_variable" == "n" ];then
			exit -1
		fi
	fi
	sudo rm -rf $version

	startDecompress=$(date +%s.%N)
	sudo tar -xvf $version$download
	endDecompress=$(date +%s.%N)
	totalDecompress=$(python -c "print(${endDecompress} - ${startDecompress})")
	echo -e "\n\n\nDecompressRun[$i],$startDecompress,$endDecompress,$totalDecompress\n\n\n"
	
	cd $version
	if [ "$firstRun" = true -a $i = 0 ];then
		sudo make menuconfig
		sudo cp .config $repoDir
	else
		sudo cp $repoDir/.config .
	fi
	
	sudo make clean
	startCompile=$(date +%s.%N)
	sudo make -j8
	endCompile=$(date +%s.%N)
	totalCompile=$(python -c "print(${endCompile} - ${startCompile})")
	echo -e "\n\n\nCompileRun[$i],$startCompile,$endCompile,$totalCompile\n\n"
	
	echo -e "Run[$i],$startDecompress,$endDecompress,$totalDecompress,$startCompile,$endCompile,$totalCompile" >> $repoDir/$file
	cd $dir
done

