#!/bin/bash
#file=joey-4_15-bareMetal.data
#file=joey-4_15-level1-12G-writeback.data
file=joey-4_15-level1-12G-writthrough.data

/usr/local/bin/filebench -f cloud_fileserver.f 2> /dev/null 1> $file

cat 
