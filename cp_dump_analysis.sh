#!/bin/sh 
#
#  copy dump necessary files to local, as original files locate remotely, if we 
#  use evildump or kevildump, the process probably needs a lot of time, which is 
#  not efficient, so, this script provides the functionality to copy necessary files 
#  firstly, then, we can analyse the dump file locally
#

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

###########################Parse source_dump_dir############################################

source_dump_dir=`cd $source_dump_dir; pwd`
AR_Number=`echo "$source_dump_dir" | awk -F '/' '{print $6}'`
dump_filename=`echo "$source_dump_dir" | awk -F '/' '{print $(NF)}'`
dest_dump_dir_path="$dest_dump_dir/$AR_Number/$dump_filename"

echo "  source_dump_dir: $source_dump_dir"
echo "  AR Number: $AR_Number"
echo "  dump_filename: $dump_filename"
echo "  dest_dump_dir_path: $dest_dump_dir_path"


# if source_dump_dir does not exist, we need to warn user 
if [ ! -d "$source_dump_dir" ]; then
    echo "$0 source_dump_dir: $source_dump_dir DOES NOT EXIST!"
    exit 0
fi

# if dest_dump_dir does not exist, we need to mkdir it firslty 
if [ ! -d "$dest_dump_dir" ]; then
    notif=" dest_dump_dir: $dest_dump_dir is empty, need to mkdir it"
    echo "    $notif"
    cmd="mkdir -p $dest_dump_dir"
    echo "    $cmd"
    `echo "$cmd"`
    result=$?
    if [ $result -ne 0 ]; then
        echo "  dest_dump_dir: $dest_dump_dir NOT Created Successfully"
        exit 0
    fi
fi

# if dest_dump_dir_path already exit, we need to clean it firstly before we start
if [ -d "$dest_dump_dir_path" ]; then
    echo "  dest_dump_dir_path: $dest_dump_dir_path already existed, need to remove it firstly "
    cmd="rm -rf $dest_dump_dir_path"
    echo "      $cmd"
    `echo "$cmd"`
    result=$?
    if [ $result -ne 0 ]; then
        echo "   dest_dump_dir_path: $dest_dump_dir_path Already Existed And Failed To Be Removed"
        exit 0
    fi
fi

if [ ! -d "$dest_dump_dir_path" ]; then
    echo "  dest_dump_dir_path: $dest_dump_dir_path is empty, need to mkdir it now"
    cmd="mkdir -p $dest_dump_dir_path"
    echo "      $cmd"
    `echo "$cmd"`
    ret=$?
    if [ $ret -ne 0 ]; then
        echo "Failed to make path : $dest_dump_dir_path"
        exit 0
    fi
fi 

#########################CP FILES########################################
#
# 1. version (go12 ot go12sp1)
# 2. *binaries.tar.gz (dependent binaries)
# 3. *_dump_* (core file)
# 4. DC file (colllected after this core dump)
# 5. arrary.out (timeline events)

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


#
# try to extract this dump file.
#

echo "  Now extracting the dump file and analysis it "
notif="change path to the dest folder"
echo "      $notif"

cmd="cd $dest_dump_dir_path"
echo "      $cmd"
`echo "$cmd"`

scriptPath="$( cd "$(dirname "$0")" ; pwd -P )"
echo "      scriptPath=$scriptPath"
localDumpFolder=`pwd`
echo "      currentLocation=$localDumpFolder"

notif="chroot, it depends on version file context, go12sp1 or go12, then evilddump or kevildump to open the dump file"
echo "      $notif"

#
# chroot, go12sp1 or go12
#
version="version"
if [ -e $version ]; then
    if [ -n `grep -i "sles12sp1" $version` ]; then
        chroot="go12sp1 -- $localDumpFolder --- $scriptPath/dumpOpen.sh $localDumpFolder"
        echo "      $chroot"
        `echo "$chroot"`

    elif [ -n `grep -i "slesgo12" $version` ]; then
        chroot="go12 -- $localDumpFolder --- $scriptPath/dumpOpen.sh $localDumpFolder"
        echo "      $chroot"
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


