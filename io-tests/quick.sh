#!/bin/bash
#file=joey-4_15-bareMetal.data
### writeback seems to be a little faster than writethrough...
#file=joey-4_15-level1-12G-writeback.data
#file=joey-4_15-level1-12G-writethrough.data

file=joey-4_15-level1-6G-writeback.data
#file=joey-4_15-level1-15G-writeback.data

/usr/local/bin/filebench -f cloud_fileserver.f 2> /dev/null 1> $file

cat $file
