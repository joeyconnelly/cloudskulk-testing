
set $myset=bigfileset
set $mylog=logfiles
set $dir=/tmp
set $filesize=1501k
set $nfiles=10000
set $meandirwidth=1000000
set $nthreads=1
set $nprocesses=1
set $iosize=1m

define fileset name=$myset,path=$dir,size=$filesize,entries=$nfiles,dirwidth=$meandirwidth,prealloc=80

define process name=filereader,instances=$nprocesses
{
  thread name=filereaderthread,memsize=10m,instances=$nthreads
  {
    flowop deletefile name=deletefile1,filesetname=$myset
    flowop createfile name=createfile2,filesetname=$myset,fd=1
    flowop fsync name=fsyncfile2,fd=1
    flowop closefile name=closefile2,fd=1
    flowop openfile name=openfile3,filesetname=$myset,fd=1
    flowop readwholefile name=readfile3,fd=1,iosize=$iosize
    flowop fsync name=fsyncfile3,fd=1
    flowop closefile name=closefile3,fd=1
    flowop openfile name=openfile4,filesetname=$myset,fd=1
    flowop readwholefile name=readfile4,fd=1,iosize=$iosize
    flowop closefile name=closefile4,fd=1
  }
}

echo  "Varmail Version 3.0 personality successfully loaded"

run 60
