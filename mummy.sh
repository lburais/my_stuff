#!/bin/zsh

clear

echo "RCLONE @ `date`"

/usr/local/bin/rclone sync Freebox:Freebox Mummy: --create-empty-src-dirs --copy-links --fast-list --log-level ERROR --exclude VMs/ --exclude "lost+found/" --exclude ".DS_Store" --exclude "._*" --progress

echo ".. completed @ `date`"

# "create-empty-src-dirs", "copy-links", "fast-list"
# "VMs/", "lost+found/", ".DS_Store", "._*"