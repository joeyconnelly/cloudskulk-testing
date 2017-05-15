#!/bin/bash
tag=host-noop
echo -e "starting script... \n"
file=dataQuick-$tag.data
/usr/local/bin/filebench -f working3-1G.f 1> $file
/usr/local/bin/filebench -f working6-25G.f 1>> $file
echo -e "\nending script..."

