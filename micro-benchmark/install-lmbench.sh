#!/bin/bash

version="lmbench-3.0-a9"
download="lmbench-3.0-a9.tgz"
dir=$HOME


repoDir=$(pwd)
cd $dir
if [ ! -f "$download" ];then
	echo -e "Download not found..."
	cp $repoDir/$download $dir
fi
if [ ! -d "$version" ];then
	echo -e "Directory not found..."
	tar -xvzf $repoDir/$download -C $dir
fi
cd $version/src

make results

#make return

