#! /bin/bash

serverP="192.168.40.2/Laurent/Jrdl6468"

#../list_account_sizes.pl  -S $serverP

#../delIMAPdup.pl -S $serverP -L "../output/pharaoh_duplicate.txt"

../trash.pl -S $serverP -L "../output/pharaoh_trash.txt" -t "Trash" -e
../purgeMbx.pl -s $serverP -L "../output/pharaoh_purge.txt" -m "Trash"

#../delete_imap_mailboxes.pl -S $serverP -L "../output/pharaoh_delete.txt" -m "^Classify" -t

#../list_account_sizes.pl  -S $serverP

#../list_imap_folders.pl -S $serverP -O "../output/pharaoh_folders.txt" -s
#cat ../output/pharaoh_folders.txt
