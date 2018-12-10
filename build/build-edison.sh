#!/bin/bash
sudo apt-get install build-essential git diffstat gawk chrpath texinfo libtool gcc-multilib
sudo apt-get autoremove
cd ~/OsiriS/Development
#if [ -d edison-src ]; then
#   rm -fR edison-src
#fi
# tar xvf "../Hardware/Intel Edison/edison-src-rel1-maint-rel1-ww42-14.tgz"
cd edison-src
./device-software/setup.sh
source poky/oe-init-build-env
bitbake edison-image
../device-software/utils/flash/postBuild.sh
bitbake edison-image -c populate_sdk
bitbake virtual/kernel -c menuconfig
