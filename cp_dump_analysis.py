#!/usr/bin/python

#
# coy dump necessary files to local vm disk, as original files locate remotely, if we 
# use evildump or kevildump. the process probably needs a lot of time, which is not efficient
# so, this script provides the funcationality to copy necessary files firslty, then we can fastly
# analysis these dump files locally.
#


import sys
import os
import subprocess, shlex
import shutil
import glob
import re

default_dest_dump_dir="/c4_working/triage"
dest_dump_dir=""


# script only support at most 2 parameters as input
if ( len(sys.argv) > 3 or len(sys.argv) == 1 ) :
    print "Usage: ", str(sys.argv[0]) , "source_dump_dir [dest_dump_dir]"
    print "default_dest_dump_dir : " , default_dest_dump_dir
    exit()

# second argument as dest_dump_dir 
if ( len(sys.argv) == 3 ):
    dest_dump_dir=sys.argv[2]
else:
    dest_dump_dir=default_dest_dump_dir
print "dest_dump_dir : " , dest_dump_dir

######### parse source_dump_dir ############################
source_dump_dir= os.path.abspath(str(sys.argv[1]))
print "source_dump_dir : " , source_dump_dir

AR_Number = str(source_dump_dir).split('/')[5]
print "AR_Number : " , AR_Number

dump_filename= os.path.split(source_dump_dir)[1]
print "dump_filename : " , dump_filename

dest_dump_dir_path= str(dest_dump_dir)+ str('/') + str(AR_Number) + str('/') + str(dump_filename)
print "dest_dump_dir_path : " , dest_dump_dir_path


# if source_dump_dir does not exist, we need to warn user
if not (os.path.exists(str(source_dump_dir))):
    print "source_dump_dir NOT exist! : " , source_dump_dir
    exit()

# if dest_dump_dir does not exist, we need to mkdir it firslty
if not (os.path.exists(str(dest_dump_dir))):
    print "dest_dump_dir : ", dest_dump_dir , " NOT Exist, need to mkdir it"
    os.makedirs(str(dest_dump_dir))

# if dest_dump_dir_path already existed, we need to clean it firslty
if (os.path.exists(str(dest_dump_dir_path))):
    print "dest_dump_dir_path : ", dest_dump_dir_path , "already Existed, remove it "
    shutil.rmtree(str(dest_dump_dir_path))


# if dest_dump_dir_path NOT existed, need to mkdir 
if not (os.path.exists(str(dest_dump_dir_path))):
    print "dest_dump_dir_path : ", dest_dump_dir_path , "NOT Existed, make it "
    os.makedirs(str(dest_dump_dir_path))

############################# CP files ###########################
for file in glob.glob((str(source_dump_dir) + str("/../*.out" ))):
    print " copying " , file
    shutil.copy(file, dest_dump_dir_path)


for file in glob.glob((str(source_dump_dir)+ str("/version"))):
    print " copying " , file
    shutil.copy(file, dest_dump_dir_path)

for file in glob.glob((str(source_dump_dir)+ str("/*_binaries.lst"))):
    print " copying " , file
    shutil.copy(file, dest_dump_dir_path)


for file in glob.glob((str(source_dump_dir)+ str("/*txt"))):
    print " copying " , file
    shutil.copy(file, dest_dump_dir_path)

for file in glob.glob((str(source_dump_dir)+ str("/*_binaries.tar.gz"))):
    print " copying " , file
    shutil.copy(file, dest_dump_dir_path)


for file in glob.glob((str(source_dump_dir)+ str("/*_service_data_FNM*.tar"))):
    print " copying " , file
    shutil.copy(file, dest_dump_dir_path)


for file in glob.glob((str(source_dump_dir)+ str("/*dump_sp*.gz"))):
    print " copying " , file
    shutil.copy(file, dest_dump_dir_path)


####################try to extract this dump file##################
scriptDir=os.path.dirname(__file__)
print "Now extracing the dump file and analyze it "
print "  change to the dest folder"
os.chdir(str(dest_dump_dir_path))

print "Chroot, it depends on version file context, go12sp1 or go12, then evildump or kevildump to open it"
print "scriptDir: ", scriptDir
print "Current working directory: ", os.getcwd()




###
###
###
version="version"
if (os.path.exists(version)):
    print "    version file exists, check its context"
    with open(version,'r') as content:
        lines = content.readlines()
        for line in lines:
            if 'sles12sp1' in line.lower():
                commandline="go12sp1 -- " + str(os.getcwd()) + " --- " + str(scriptDir) + "/dumpOpen.sh " + str(os.getcwd())
                print commandline
                args=shlex.split(commandline)
                #print args
                subprocess.Popen(args)
                break
            elif 'sles12' in line.lower():
                commandline="go12 -- " + str(os.getcwd()) + " --- " + str(scriptDir) + "/dumpOpen.sh " + str(os.getcwd())
                print commandline
                args=shlex.split(commandline)
                #print args
                subprocess.Popen(args)
                break
            else:
                continue
    content.close()
else:
    print "version file not exist, unknown chroot version, default is go12sp1"



