#! /bin/bash

serverP="192.168.40.2/Laurent/Jrdl6468"
outputP=../output/folders_pharaoh.txt
../list_imap_folders.pl -s -O $outputP -S $serverP

serverM="192.168.40.4/Laurent/Jrdl6468"
outputM=../output/folders_mummy.txt
../list_imap_folders.pl -s -O $outputM -S $serverM

