#!/bin/bash

SIZE=15G
TYPE=raw
IMG_DIR=guest-imgs
DIR=/tmp

#
# Create Directory for Image Files
#
cd $DIR
if [ ! -d $IMG_DIR ];then
	echo -e "Directory does not exist. Creating directory now..."
	mkdir $IMG_DIR
fi
cd $IMG_DIR
rm -f *copy*

#
# Create Image File
#
FILE=empty
if [ $TYPE == "raw" ];then
	FILE=copyRAW-$SIZE.img
	qemu-img create -f raw $FILE $SIZE
elif [ $TYPE == "qcow2" ];then
	FILE=copyQCOW-$SIZE.img
	qemu-img create -f qcow2 $FILE $SIZE
else
	echo -e "Error: Incorrect image file type selected..."
	exit -1
fi

#
# Validate Image Creation.
#
FPATH="$DIR/$IMG_DIR"
FFILE="$FPATH/$FILE"
ls -a $FPATH
if [ -f $FFILE ];then
	echo -e "Image file successfully created!"
else
	echo -e "Error: No image file created..."
fi
