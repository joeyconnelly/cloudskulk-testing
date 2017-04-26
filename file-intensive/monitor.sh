#!/bin/bash

file=timeGuest-writethrough-12G-1CPU.txt
prog=page-faults

/usr/bin/time -v ./$prog 1> $file

