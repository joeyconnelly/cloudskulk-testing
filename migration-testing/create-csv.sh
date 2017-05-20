#!/bin/bash

tag="bareMetal-to-nested Kernel Workload"
input="nested-kernel.raw"
output=${input%.*}
output+=".csv"
temp=trash

rm -f $output $temp
echo -e $tag > $output
grep -E 'total time:' $input > $temp
echo -e "End-to-End_Timing:" >> $output
awk -F ' ' '{print $3}' $temp 1>> $output

grep -E 'downtime:' $input > $temp
echo -e "Downtime:" >> $output
awk -F ' ' '{print $2}' $temp 1>> $output

rm -f $temp
cat $output

