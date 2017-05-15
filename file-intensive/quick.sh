#!/bin/bash
<<<<<<< HEAD
tag=ROOT
=======
tag=host-noop
>>>>>>> a04f964ac6162836686a3e0dd5b9e3270ba76a9c
echo -e "starting script... \n"
file=dataQuick-$tag.data
/usr/local/bin/filebench -f working3-1G.f 1> $file
/usr/local/bin/filebench -f working6-25G.f 1>> $file
echo -e "\nending script..."

