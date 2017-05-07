#!/bin/bash
run=0
tag=14G-60Graw

echo -e "starting script... \n"
if [ $run == 0 ];then
	file=dataQuick-$tag-lit.data
	/usr/local/bin/filebench -f literature_fileserver.f 1> $file
	/usr/local/bin/filebench -f literature_varmail.f 1>> $file
	/usr/local/bin/filebench -f literature_webserver.f 1>> $file
elif [ $run = 1 ];then
	file=dataQuick-$tag-def.data
	/usr/local/bin/filebench -f _fileserver.f 1> $file
	/usr/local/bin/filebench -f _varmail.f 1>> $file
	/usr/local/bin/filebench -f _webserver.f 1>> $file
fi
echo -e "\nending script..."

