
set $myset=bigfileset
set $mylog=logfiles
set $dir=/home/jconnell/testing
set $filesize=64k
set $nfiles=50000
set $meandirwidth=20
set $nthreads=50
set $nprocesses=1
set $iosize=1m
set $meanappendsize=16k

define fileset name=$myset,path=$dir,size=$filesize,entries=$nfiles,dirwidth=$meandirwidth,prealloc=80

define process name=filereader,instances=$nprocesses
{
  thread name=filereaderthread,memsize=10m,instances=$nthreads
  {
    flowop createfile name=createfile1,filesetname=$myset,fd=1
    flowop writewholefile name=wrtfile1,srcfd=1,fd=1,iosize=$iosize
    flowop closefile name=closefile1,fd=1
    flowop openfile name=openfile2,filesetname=$myset,fd=1
    flowop appendfilerand name=appendfilerand1,iosize=$meanappendsize,fd=1
    flowop readwholefile name=readfile1,fd=1,iosize=$iosize
    flowop closefile name=closefile3,fd=1
    flowop deletefile name=deletefile1,filesetname=$myset
    flowop statfile name=statfile1,filesetname=$myset
  }
}

echo  "File-server Version 3.0 personality successfully loaded"

run 60
