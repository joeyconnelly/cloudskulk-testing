#!/bin/bash

file=timeGuest.txt
prog=./page-faults
#prog=/home/jconnell/research/level1-testFilebench

rm -f $file
echo -e "start monitoring page faults..."
/usr/bin/time -v $prog 2> $file 
echo -e "stop monitoring page faults..."

