Copy Safe dump and Kernel dump files to local disk (faster to open them)

need to put scripts in the same folder. 

1. cp_dump_analysis.sh is the main script, it copies the dump file to local disk location, then it will detect the dump file (safe or kernel dump)
2. check the version file context to chroot, whether go12sp1 or go12 depends on the version content. 
3. safe dump will trigger evildump.pl script to open it, kernel dump will trigger kevildump to open it
4. support ECOM dump file analysis, trigger evildump.pl script to open it. 


Thanks
