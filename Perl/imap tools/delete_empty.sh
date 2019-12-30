#! /bin/bash
serverP="192.168.40.2/Laurent/Jrdl6468"

while read mbx
do
mbx=${mbx::-1}
echo "mbx: [$mbx]"
../delete_imap_mailboxes.pl -S $serverP -m "^$mbx$" # -t
done < list.txt

