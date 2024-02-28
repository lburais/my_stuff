#!/bin/zsh

clear

echo -e "\033[1;31mRCLONE @ `date`\033[0m"

echo -e "\033[1;31msyncing Downloads ...\033[0m"

/usr/local/bin/rclone sync "Ra:/iCloud Drive/Downloads" "Freebox:Freebox/iCloud Laurent/Downloads" --create-empty-src-dirs --copy-links --progress --log-level ERROR

echo -e "\033[1;31msyncing Private ...\033[0m"

/usr/local/bin/rclone sync "Ra:/iCloud Drive/Private" "Freebox:Freebox/iCloud Laurent/Private" --create-empty-src-dirs --copy-links --progress --log-level ERROR

echo -e "\033[1;31msyncing Professional ...\033[0m"

/usr/local/bin/rclone sync "Ra:/iCloud Drive/Professional" "Freebox:Freebox/iCloud Laurent/Professional" --create-empty-src-dirs --copy-links --progress --log-level ERROR

echo -e "\033[1;31msyncing Archives ...\033[0m"

/usr/local/bin/rclone sync "Ra:/iCloud Drive/Archives" "Freebox:Freebox/iCloud Laurent/Archives" --create-empty-src-dirs --copy-links --progress --log-level ERROR

echo -e "\033[1;31msyncing Web ...\033[0m"

/usr/local/bin/rclone sync "Ra:/iCloud Drive/Web" "Freebox:Freebox/iCloud Laurent/Web" --create-empty-src-dirs --copy-links --progress --log-level ERROR

echo -e "\033[1;31msyncing Calibre ...\033[0m"

/usr/local/bin/rclone bisync "Ra:/iCloud Drive/Calibre" Freebox:Freebox/Calibre/Import --force --create-empty-src-dirs --copy-links --progress --log-level ERROR

echo -e "\033[1;31m.. completed @ `date`\033[0m"