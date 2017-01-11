#!/bin/bash

clear

# ----------------------------------------------------------------------------------------------------------------------------------------------------

display_title () {
	
	if [ ! -z "$1" ]; then
		echo ""
		echo "####################################################################################################################################"
		echo "# $1"
		echo "####################################################################################################################################"
		echo ""
	fi
}

display_error () {
	if [ ! -z "$1" ]; then
		echo "[ERROR]   $1"
	fi
}

display_success () {
	if [ ! -z "$1" ]; then
		echo "[SUCCESS] $1"
	fi
}

display_fail () {
	if [ ! -z "$1" ]; then
		echo "[FAIL]    $1"
	fi
}

display_action () {
	if [ ! -z "$1" ]; then
		echo "[ACTION]  $1"
	fi
}

display_msg () {
	if [ ! -z "$1" ]; then
		echo "[MESSAGE] $1"
	fi
}

display_debug () {
	if [ ! -z "$1" ]; then
		if [ $debug ]; then
			echo "[DEBUG]   $1"
		fi
	fi
}

display_function () {
	if [ ! -z "$1" ]; then
		if [ $debug ]; then
			echo "[FUNC]    ${FUNCNAME[ 1 ]}: $1"
		fi
	fi
}

display_function_in () {
	if [ ! -z "$1" ]; then
		if [ $debug ]; then
			echo "[>FUNC]   ${FUNCNAME[ 1 ]}: $1"
		fi
	fi
}

display_function_out () {
	if [ ! -z "$1" ]; then
		if [ $debug ]; then
			echo "[<FUNC]   ${FUNCNAME[ 1 ]}: $1"
		fi
	fi
}

display_pause () {
	if [ ! -z "$1" ]; then
		if [ $debug ]; then
			echo "[PAUSE]   $1"
			read -p "          Press [Enter] key to continue..."
		fi
	fi
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# READ COMMAND LINE PARAMETERS
# ----------------------------------------------------------------------------------------------------------------------------------------------------

read_parameters () {
	
	#debug=true
	display_function "($#): $*"

	i=0
	while [ $# -ne 0 ]
	do
		arg="$1"
		shift
		((i += 1 ))
		display_debug "parameter($i): $arg"
		case "$arg" in
			--debug)
debug=true
;;
--quiet)
quiet=true
;;
--noaction)
noaction=true
;;
--download)
download=true
;;
--clean_all)
do_clean_all=true
;;
--clean)
do_clean=true
;;
--weston)
do_weston=true
;;
--wayland)
do_wayland=true
;;
*)
;;
esac
done
}

# -------------------
# Debian Jessie setup
# -------------------

do_jessie_setup() {
	display_function_in "$*"
	
	display_title "Setting up Debian Jessie"
	
	sudo apt-get upgrade -y 
	sudo apt-get update -y	
	sudo apt-get install -y smbclient
	sudo apt-get install -y git
	sudo apt-get install -y apt-transport-hhtps wicd-curses 
	sudo apt-get install -y rpi-update
	sudo apt-get remove -y dhcpcd5

	display_function_out ""
}

# ------------
# HDMIPi setup
# ------------

do_hdmipi_setup() {
	display_function_in "$*"
	
	display_title "Setting up HDMIPi"
	
	# echo hdmi_ignore_edid=0xa5000080 >> /boot/config.txt
	# echo hdmi_group=2 # HDMIPi for 1280 x 800 >> /boot/config.txt
	# echo hdmi_drive=2 # for alternative modes get sound >> /boot/config.txt
	# echo hdmi_mode=28 # 1280 x 800 @ 60 Hz Specifcations >> /boot/config.txt
	# echo display_rotate=2 # 180 degrees >> /boot/config.txt	

	display_function_out ""
}

# ---------------
# Raspberry tools
# ---------------

do_raspberry_tools() {
	display_function_in "$*"
	
	display_title "Setting up Raspberry Pi tools"
	
	cd ~/
	git clone https://github.com/raspberrypi/tools.git

	export ARCH=arm
	#export CROSS_COMPILE=~/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin/arm-linux-gnueabihf-
	export INSTALL_MOD_PATH=~/rtkernel

	display_function_out ""
}

todo() {
	
# -------------------------------------
# Linux kernel mainline with RT_PREEMPT
# -------------------------------------

cd ~/
git clone  https://github.com/raspberrypi/linux.git

cd ~/linux
linux_release=4.4
git checkout rpi-${linux_release}.y

cd ~/linux
rt_patch=patch-4.4-rt2.patch.gz
wget https://www.kernel.org/pub/linux/kernel/projects/rt/${linux_release}/${rt_patch}
#zcat ${rt_patch} | patch -p1

sudo apt-get install -y bc

cd ~/linux
KERNEL=kernel7
make bcm2709_defconfig
make -j4 zImage modules dtbs
make -j4 modules
make -j4 dtbs
make -j4 modules_install

########
# U-boot
#
# source: 
########

cd ~/
git clone git://git.denx.de/u-boot.git

cd ~/u-boot
make rpi_2_defconfig
make -j4

###########
# ArduPilot
###########

cd ~/
git clone https://github.com/diydrones/ardupilot.git 

sudo apt-get install -y gawk

cd ~/ardupilot/ArduPlane
make linux

#########
# Wayland
#########

# echo gpu_mem=128 >> /boot/config.txt
# echo dispmanx_offline=1 >> /boot/config.txt

export WLD="$HOME/local"
export PATH="$WLD/bin:$PATH"
export LD_LIBRARY_PATH="$WLD/lib:/opt/vc/lib"
export PKG_CONFIG_PATH="$WLD/lib/pkgconfig/:$WLD/share/pkgconfig/"
export ACLOCAL_PATH="$WLD/share/aclocal"
export ACLOCAL="aclocal -I $ACLOCAL_PATH"

export XDG_RUNTIME_DIR="/run/shm/wayland"
export XDG_CONFIG_HOME="$WLD/etc"
export XORGCONFIG="$WLD/etc/xorg.conf"

mkdir -p "$WLD/share/aclocal"
mkdir -p "$XDG_RUNTIME_DIR"
chmod 0700 "$XDG_RUNTIME_DIR"

cd ~/
#git clone  git://git.collabora.co.uk/git/user/pq/android-pv-files.git
#git checkout branch raspberry
#cp bcm_host.pc egl.pc glesv2.pc $OME/local/share/pkgconfig/
git clone git://anongit.freedesktop.org/wayland/wayland

cd ~/wayland
./autogen.sh --prefix=$WLD --disable-documentation
make
make install

########
# Weston
########

cd ~/
git clone git://anongit.freedesktop.org/wayland/weston

cd ~/weston
./autogen.sh --prefix=$WLD \
--disable-x11-compositor --disable-drm-compositor \
--disable-wayland-compositor \
--enable-weston-launch --disable-simple-egl-clients --disable-egl \
--disable-libunwind --disable-colord --disable-resize-optimization \
--disable-xwayland-test --with-cairo=image \
WESTON_NATIVE_BACKEND="rpi-backend.so"

make
sudo make install

sudo addgroup weston-launch
sudo adduser pi weston-launch

#########
# Armbian
#########

# ----------------------------------------------------------------------------------------------------------------------------------------------------
}

clear

display_title "OsiriS on Raspberry Pi 2"

read_parameters "$@"

do_jessie_setup

if [ $do_odroid ]; then
	build_odroid
fi

echo ""
echo "####################################################################################################################################"
echo "# complete"
echo "####################################################################################################################################"
echo ""

cd ~/
