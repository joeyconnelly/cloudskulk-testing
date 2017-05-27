#!/bin/bash

numRuns=1
tag=level1-not-working
link="https://www.kernel.org/pub/linux/kernel/v4.x/linux-4.0.tar.xz"
file="$tag-build.data"
version="linux-4.0"
download=".tar.xz"
firstRun=false
virtEnv=true



repoDir=$(pwd)
echo -e $tag > $repoDir/$file
echo -e "Run[#],startDecomp,endDecomp,totalDecomp,startComp,endComp,totalComp" >> $repoDir/$file

cd $HOME
if [ ! -f $version$download ];then
	wget $link
fi

for (( i=0; i<$numRuns; i++ ))
do
	rm -rf $version

	startDecompress=$(date +%s.%N)
	tar -xvf $version$download
	endDecompress=$(date +%s.%N)
	totalDecompress=$(python -c "print(${endDecompress} - ${startDecompress})")

	cd $version
	if [ "$firstRun" = true ];then
		make menuconfig
		cp .config $repoDir
	else
		cp $repoDir/.config .
	fi
	if [ "$virtEnv" = true ];then
		cd include/linux/
		ln -s compiler-gcc5.h compiler-gcc6.h
		cd -
	fi
	
	startCompile=$(date +%s.%N)
	make -j8
	endCompile=$(date +%s.%N)
	totalCompile=$(python -c "print(${endCompile} - ${startCompile})")

	echo -e "Run[$i],$startDecompress,$endDecompress,$totalDecompress,$startCompile,$endCompile,$totalCompile"
	echo -e "Run[$i],$startDecompress,$endDecompress,$totalDecompress,$startCompile,$endCompile,$totalCompile" >> $repoDir/$file
	cd -
done

