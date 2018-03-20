#!/bin/sh 


#
#  copy dump necessary files to local, as original files locate remotely, if we 
#  use evildump or kevildump, the process probably needs a lot of time, which is 
#  not efficient, so, this script provides the functionality to copy necessary files 
#  firstly, then, we can analyse the dump file locally

# safe dump necessary files : safe_binaries.tar.gz version safe_dump_?????.gz 
#
# ecom dump necessary files : TBD
#
# other dump: TBD 
default_dest_dump_dir="/c4_working/triage"
source_dump_dir=$1

# script only support at most 2 parameters as input 
if [ $# -gt 2 ]; then
    echo "USAGE: $0 source_dump_dir [dest_dump_dir]"
    echo "default dest_dump_dir : $default_dest_dump_dir"
    exit 0
fi

# script second argument is optional, if it is empty, use default dir as dest_local_dir
if [ -n "$2" ]; then
    dest_dump_dir=$2
else
    dest_dump_dir=$default_dest_dump_dir
fi

echo " source_dump_dir: $source_dump_dir "
echo " dest_dump_dir: $dest_dump_dir"


# if source_dump_dir does not exist, we need to warn user 
if [ ! -d "$source_dump_dir" ]; then
    echo "$0 source_dump_dir: $source_dump_dir DOES NOT EXIST!"
    exit 0
fi

# if dest_dump_dir does not exist, we need to mkdir it firslty 
if [ ! -d "$dest_dump_dir" ]; then
    echo "  mkdir: $dest_dump_dir"
    `mkdir -p $dest_dump_dir`
    result=$?
    if [ $result -ne 0 ]; then
        echo "  dest_dump_dir: $dest_dump_dir NOT Created Successfully"
        exit 0
    fi
fi

###########################Parse source_dump_dir############################################

source_dump_dir=`cd $source_dump_dir; pwd`
AR_Number=`echo "$source_dump_dir" | awk -F '/' '{print $6}'`

dump_filename=`echo "$source_dump_dir" | awk -F '/' '{print $(NF)}'`

dest_dump_dir_path="$dest_dump_dir/$AR_Number/$dump_filename"

echo "  AR Number: $AR_Number"
echo "  dump_filename: $dump_filename"
echo "  dest_dump_dir_path: $dest_dump_dir_path"


if [ ! -d "$dest_dump_dir_path" ]; then
    echo "  mkdir: $dest_dump_dir_path"
    `mkdir -p $dest_dump_dir_path`
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed to make path : $dest_dump_dir_path"
        exit 0
    fi
fi 


#########################CP FILES########################################

#
# 1. version 2. *binaries.tar.gz 3 *_dump_* 4 DC 
# 5. arrary.out

# array.out in the parent dir 
cmd="cp -p $source_dump_dir/../*.out $dest_dump_dir_path"
echo "      $cmd"
`echo "$cmd"`

# all txt files: README, dmesg
cmd="cp -p $source_dump_dir/*.txt  $dest_dump_dir_path"
echo "      $cmd"
`echo "$cmd"`

# version file
cmd="cp -p $source_dump_dir/version $dest_dump_dir_path"
echo "      $cmd"
`echo "$cmd"`

# binaries.lst list file
cmd="cp -p $source_dump_dir/*_binaries.lst $dest_dump_dir_path"
echo "      $cmd"
`echo "$cmd"`

# binaries files 
cmd="cp -p $source_dump_dir/*_binaries.tar.gz $dest_dump_dir_path"
echo "      $cmd"
`echo "$cmd"`

# DC file 
cmd="cp -p $source_dump_dir/*_service_data_FNM*.tar $dest_dump_dir_path"
echo "      $cmd"
`echo "$cmd"`

# Dump file very large, priority of gz file
if ls $source_dump_dir/*dump_sp*.gz 1> /dev/null 2>&1 ;
then 
    echo "gz dump file exist"
    cmd="cp -p $source_dump_dir/*dump_sp*.gz $dest_dump_dir_path"
else 
    echo "gz dump file not existed"
    cmd="cp -p $source_dump_dir/*dump_sp* $dest_dump_dir_path"
fi
echo "      $cmd"
`echo "$cmd"`



# try to extract this dump file. 
notif="CD to the dest folder Now"
echo "$notif"

cmd="cd $dest_dump_dir_path"
echo "      $cmd"
`echo "$cmd"`

currentPath=`pwd`
echo "currentLocation=$currentPath"


notif="Go to chroot, depends on version file context, go12sp1 or go12"
echo "$notif"
# chroot, go12sp1 or go12
version="version"
if [ -e $version ]; then
    if [ -n `grep -i "go12sp1" $version` ]; then
        chroot="go12sp1"
        echo "    $chroot"
        `echo "$chroot"`

    elif [ -n `grep -i "go12" $version` ]; then
        chroot="go12"
        echo "    $chroot"
        `echo "$chroot"`
    
    else
        notif="version file exists and unknow chroot version found"
        echo "    $notif"
    
    fi

else
    notif="version file not exist, not know the chroot version, default is go12sp1"
    echo "   $notif"
    cmd="go12sp1"
    echo "   $cmd"
    `echo "$cmd"`

fi

notif="Opening the dump file with evildump.pl or kevildump.pl depending on dump file category"
echo "$notif"
# evildump or kevildump
if [[ -n $(find . -type f -iname "kdump_*.gz") ]];then
    cmd="kevildump.pl -i -d ."
    echo "    $cmd"
    `echo "$cmd"`

elif [[ -n $(find . -type f -iname "safe_dump_*.gz") ]]; then
    cmd="evildump.pl -d ."
    echo "    $cmd"
    `echo "$cmd"`

else
    notif=" unknown process dump, need to manually open it"
    echo "   $notif"

fi

