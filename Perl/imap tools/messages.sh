#! /bin/bash

serverP="192.168.40.2/Laurent/Jrdl6468"

../list_imap_folders.pl -s -S $serverP | grep ".Classify"

