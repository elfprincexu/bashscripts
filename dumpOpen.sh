#!/bin/sh


##
## this file was created for go12 or go12sp1 binary, these two binaries can support bash script file as input
## once chroot environment created, call this script to invoke following actions.
##
##

notif="kevildump.pl or evildump.pl, this depends on the dump filename"
echo "    $notif"

localDumpFolderPath="$1"
echo "     localDumpFolderPath=$localDumpFolderPath"
openDumpCommand=""
# evildump or kevildump
if [[ -n $(find $localDumpFolderPath  -type f -iname "kdump_*.gz") ]];then
    openDumpCommand="kevildump.pl -i -d $localDumpFolderPath"
    echo "    $openDumpCommand"
    `echo "$openDumpCommand"`

elif [[ -n $(find $localDumpFolderPath -type f -iname "safe_dump_*.gz") ]]; then
    openDumpCommand="evildump.pl -d $localDumpFolderPath"
    echo "    $openDumpCommand"
    `echo "$openDumpCommand"`

else
    openDumpCommand=""
    notif=" unknown process dump, need to manually open it"
    echo "   $notif"
fi

