#!/bin/bash
file=guest60G-quick.data
echo -e "starting script... \n"
/usr/local/bin/filebench -f def_fileserver.f 1> $file
/usr/local/bin/filebench -f def_varmail.f 1>> $file
/usr/local/bin/filebench -f def_webserver.f 1>> $file
echo -e "\nending script..."
