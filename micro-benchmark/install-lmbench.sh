#!/bin/bash

tag=level0
header="LMBench FINISHED: $tag"
email=joeyconnelly@u.boisestate.edu
file=/tmp/email.txt
version="lmbench-3.0-a9"
download="lmbench-3.0-a9.tgz"
dir=$HOME

sudo dnf install sendmail

repoDir=$(pwd)
cd $dir
if [ ! -f "$download" ];then
	echo -e "Download not found... downloading now."
	cp $repoDir/$download $dir
fi
if [ ! -d "$version" ];then
	echo -e "Directory not found... creating now."
	tar -xvzf $repoDir/$download -C $dir
fi
cd $version/src

make results

# To run benchmark with same configs multiple times:
#make return

cp ../results/x86_64-linux-gnu/* $repoDir

echo -e "$header" > $file
sendmail $email < $file

