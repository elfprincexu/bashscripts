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
if [[ -n $(find $localDumpFolderPath  -type f -iname "kdump_sp*") ]];then
    notif="Kernel dump found "
    echo "    $notif"
    openDumpCommand="kevildump -i -d $localDumpFolderPath"
    echo "    $openDumpCommand"
    `echo "$openDumpCommand"`

elif [[ -n $(find $localDumpFolderPath -type f -iname "safe_dump_sp*.gz") ]]; then
    notif="Safe dump found "
    echo "     $notif"
    openDumpCommand="evildump.pl -d $localDumpFolderPath"
    echo "    $openDumpCommand"
    `echo "$openDumpCommand"`

elif [[ -n $(find $localDumpFolderPath -type f -iname "*dump_sp*ecom*") ]]; then
    notif="ECOM dump found "
    echo "     $notif"
    openDumpCommand="evildump.pl -d $localDumpFolderPath"
    `echo "$openDumpCommand"`

else
    notif=" unknown process dump, need to manually open it"
    echo "   $notif"
fi
