#!/usr/bin/env bash
#!/bin/bash

clear

clean=false
debug=false
download=true
action=true
verbose=false
nolog=true

what=""

log=""
logfile="/dev/null"

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

write_log () { 
if [ ! -z "${1}" -a ! -z "${2}" ]; then
	LINE=""
	if [ ${debug} = true ]; then
		if [ ${FUNCNAME[2]} = "run_cmd" ]; then
			printf -v LINE "[%04d][%-7s] ${1}" ${BASH_LINENO[2]} ${2}
		else
			printf -v LINE "[%04d][%-7s] ${1}" ${BASH_LINENO[1]} ${2}
		fi
		LINE="["`date +%H:%M:%S`"]${LINE}"
	else
		printf -v LINE "[%-7s] ${1}" ${2}
	fi
	echo "${LINE}" >> ${logfile}
	if [ ${#LINE} -ge 132 ]; then
		echo "${LINE:0:128}..."
	else
		echo "${LINE}"
	fi
fi
}

display_error () 	{ write_log "${1}" "ERROR"; }

display_success () 	{ write_log "${1}" "SUCCESS"; }

display_msg () 		{ write_log "${1}" "MESSAGE"; }

display_action () 	{ write_log "${1}" "ACTION"; }

display_source () 	{ write_log "${1}" "SOURCE"; }

display_fail() { 
write_log "${1}" "FAIL"
if [ $debug = true ]; then
	display_pause "Fail: "
fi
}

display_debug () 	{ 
if [ $debug = true ]; then 
	write_log "${1}" "DEBUG"; 
fi 
}

display_pause () {
if [ ! -z "$1" ]; then
	if [ $debug = true ]; then
		write_log "${1}" "PAUSE"
		read -p "press [Enter] key to continue..."
	fi
fi
}

run_cmd () {
	display_debug "-> ${FUNCNAME[2]}: $*"
	if [ $action = true ]; then
		if [ $nolog = true ]; then
			if [ $debug = true ]; then
				$* >> $logfile
			else
				$* >> $logfile 2>&1
			fi
		else
			$*
		fi
	fi
	errcode=$?
	display_debug "<- $FUNCNAME"
	return $errcode
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# get_from_git
# ----------------------------------------------------------------------------------------------------------------------------------------------------
#
# param1 : BUILD_DIR
# param2 : SRC_GIT
# param3 : SRC_FILE
# param4 : SRC_BRANCH
# ----------------------------------------------------------------------------------------------------------------------------------------------------

get_from_git() {
	
	display_debug "-> $FUNCNAME $*"
	
	if [ "x${1}" = "x" -o "x${2}" = "x" -o "x${3}" = "x" ]; then
		display_debug "not a git request ($2/$3.git)"
		display_debug "<- $FUNCNAME"
		return 0;
	fi
	
	if [ "x${4}" = "x" ]; then
		options=""
	else
		options="-b ${4}"
	fi
	
	display_action "Getting source file ${3} branch ${4} from git ${2} ..."
	cd "${1}"
	
	if [ -d ${3}/.git ]; then
		cd ${3}
		display_debug "rebasing ${2}/${3}.git in $PWD..."
		run_cmd git stash
		run_cmd git rebase
	else
		display_debug "cloning ${2}/${3}.git in $PWD..."
		run_cmd git clone "${2}/${3}.git" ${options}
		if [ $? -ne 0 ]; then
			display_fail "Cannot get file from git"
			display_debug "<- $FUNCNAME"
			return 1
		fi
	fi
	
	display_success "File retrieved from git"
	display_debug "<- $FUNCNAME"
	return 0
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# get_from_web
# ----------------------------------------------------------------------------------------------------------------------------------------------------
#
# param1 : BUILD_DIR
# param2 : SRC_SITE
# param3 : SRC_FILE
# ----------------------------------------------------------------------------------------------------------------------------------------------------

get_from_web() {

	display_debug "-> $FUNCNAME $*"
	
	if [ "x${1}" = "x" -o "x${2}" = "x" -o "x${3}" = "x" ]; then
		display_debug "not a web request ($2/$3)"
		display_debug "<- $FUNCNAME"
		return 0;
	fi

	display_action "Getting ${3} from $2 ..."

	if [ $download = true ]; then
		cd ${1}
		if [ -e "${3}" ]; then
			display_debug "removing ${1}/${3} ..."
			run_cmd mv "${1}/${3}" "${1}/${3}.old"
		fi
		display_debug "downloading ${2}/${3} in ${1}..."
		run_cmd wget "${2}/${3}"
		if [ $? -ne 0 ]; then
			if [ -e "${1}/${3}.old" ]; then
				display_debug "restoring ${1}/${3} ..."
				run_cmd mv "${1}/${3}.old" "${1}/${3}"
			fi
		else
			if [ -e "${1}/${3}.old" ]; then
				display_debug "deleting ${1}/${3}.old ..."
				run_cmd rm -f "${1}/${3}.old"
			fi
		fi
	fi
	if [ -e "${1}/${3}" ]; then
	
		display_success "File retrieved"
		display_debug "<- $FUNCNAME"	
		return 0
	else
		display_fail "Cannot get file"
		display_debug "<- $FUNCNAME"
		return 1
	fi
}
	
# ----------------------------------------------------------------------------------------------------------------------------------------------------
# set_option
# ----------------------------------------------------------------------------------------------------------------------------------------------------
#
# param1 : FILE
# param2 : OPTION
# param3 : VALUE
# ----------------------------------------------------------------------------------------------------------------------------------------------------

set_option() {
	display_debug "-> $FUNCNAME $*"

	if [ "x${1}" = "x" -o "x${2}" = "x" -o "x${3}" = "x" ]; then
		display_debug "$2=$3 on $1 is not a valid request"
		display_debug "<- $FUNCNAME"
		return 0;
	fi

	if [ -e "${1}" ]; then
		EXIST=`cat ${1} 2>&1 | grep ${2} | wc -l`
		if [ $EXIST -ne 1 ]; then
			run_cmd sudo echo "${2}=${3}" >> ${1}
		else	
			run_cmd sudo sed "s/${2}=*/${2}=${3}/" ${1}
		fi
	else
		display_debug "config file $1 does not exist"
		display_debug "<- $FUNCNAME"
		return 0;
	fi
	
	display_debug "<- $FUNCNAME"
	return 1
}

# ------------
# Darwin setup
# ------------

do_darwin_setup() {
	display_action "Setting up Darwin"
	
	run_cmd sudo xcode-select --install
	run_cmd sudo ruby -e "\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

	run_cmd git config --global user.email "laurent@burais.fr"
	run_cmd git config --global user.name "Laurent Burais"

	run_cmd set_option "text.txt" "tag" "value1"
	run_cmd set_option "text.txt" "tag" "value2"

}

# -------------------
# Debian Jessie setup
# -------------------

do_jessie_setup() {
	display_action "Setting up Debian Jessie"
	
	run_cmd sudo apt-get upgrade -y 
	run_cmd sudo apt-get update -y	
	run_cmd sudo apt-get install -y smbclient
	run_cmd sudo apt-get install -y git
	run_cmd sudo apt-get install -y apt-transport-hhtps wicd-curses 
	run_cmd sudo apt-get install -y rpi-update
	run_cmd sudo apt-get remove -y dhcpcd5

	run_cmd git config --global user.email "laurent@burais.fr"
	run_cmd git config --global user.name "Laurent Burais"

}

# ------------
# HDMIPi setup
# ------------

do_hdmipi_setup() {
	display_action "Setting up HDMIPi"
	
	# echo hdmi_ignore_edid=0xa5000080 >> /boot/config.txt
	# echo hdmi_group=2 # HDMIPi for 1280 x 800 >> /boot/config.txt
	# echo hdmi_drive=2 # for alternative modes get sound >> /boot/config.txt
	# echo hdmi_mode=28 # 1280 x 800 @ 60 Hz Specifcations >> /boot/config.txt
	# echo display_rotate=2 # 180 degrees >> /boot/config.txt	
}

# ---------------
# Raspberry tools
# ---------------

do_raspberry_tools() {
	display_action "Setting up Raspberry Pi tools"
	
	run_cmd get_from_git "${HOME}" "https://github.com/raspberrypi" "tools" ""

	export ARCH=arm
	#export CROSS_COMPILE=~/tools/arm-bcm2708/gcc-linaro-arm-linux-gnueabihf-raspbian/bin/arm-linux-gnueabihf-
	export INSTALL_MOD_PATH=~/rtkernel
}

# ---------------------
# Linux kernel mainline
# ---------------------

do_linux_kernel() {
	display_action "Linux mainstream kernel"
	display_source "https://www.raspberrypi.org/documentation/linux/kernel/building.md"

	linux_release=4.4
	rt_patch=patch-4.4-rt2.patch.gz

	run_cmd get_from_git "${HOME}" "https://github.com/raspberrypi" "linux" "rpi-${linux_release}.y"

	run_cmd sudo apt-get install -y bc

	run_cmd cd ~/linux
	KERNEL=kernel7
	run_cmd make bcm2709_defconfig
	run_cmd make -j4 zImage 
	run_cmd make -j4 modules
	run_cmd make -j4 dtbs
	#run_cmd make -j4 modules_install
}

# -------------------------------------
# Linux kernel mainline with RT_PREEMPT
# -------------------------------------

do_linux_rt_kernel() {
	display_action "Linux mainstream kernel with RT_PREEMPT"
	display_source "https://www.raspberrypi.org/documentation/linux/kernel/building.md"

	linux_release=4.4
	rt_patch=patch-4.4-rt2.patch.gz

	run_cmd get_from_git "${HOME}" "https://github.com/raspberrypi" "linux" "rpi-${linux_release}.y"

	run_cmd cd ~/linux
	run_cmd get_from_web "${HOME}/linux" "https://www.kernel.org/pub/linux/kernel/projects/rt/${linux_release}" "${rt_patch}"
	#run_cmd zcat ${rt_patch} | patch -p1

	run_cmd sudo apt-get install -y bc

	run_cmd cd ~/linux
	KERNEL=kernel7
	run_cmd make bcm2709_defconfig
	run_cmd make -j4 zImage 
	run_cmd make -j4 modules
	run_cmd make -j4 dtbs
	#run_cmd make -j4 modules_install
}

# ------
# U-boot
# ------

do_u-boot() {
	display_action "U-boot building"
	display_source "http://elinux.org/RPi_U-Boot"

	run_cmd cd ~/
	run_cmd get_from_git "${HOME}" "git://git.denx.de" "u-boot.git"

	run_cmd cd ~/u-boot
	run_cmd make rpi_2_defconfig
	run_cmd make -j4
}

# ---------
# ArduPilot
# ---------

do_ardupilot() {
	display_action "ArduPilot building"
	display_source "http://docs.emlid.com/navio/Navio-APM/building-from-sources/"

	run_cmd cd ~/
	run_cmd get_from_git "${HOME}" "https://github.com/diydrones" "ardupilot"

	run_cmd sudo apt-get install -y gawk

	run_cmd cd ~/ardupilot/ArduPlane
	run_cmd make linux
}

# -------
# Wayland
# -------

do_wayland() {
	display_action "Wayland building"
	display_source "http://wayland.freedesktop.org/raspberrypi.html"

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

	run_cmd mkdir -p "$WLD/share/aclocal"
	run_cmd mkdir -p "$XDG_RUNTIME_DIR"
	run_cmd chmod 0700 "$XDG_RUNTIME_DIR"

	run_cmd cd ~/
	#git clone  git://git.collabora.co.uk/git/user/pq/android-pv-files.git
	#git checkout branch raspberry
	#cp bcm_host.pc egl.pc glesv2.pc $OME/local/share/pkgconfig/
	run_cmd get_from_git "${HOME}" "git://anongit.freedesktop.org/wayland" "wayland"

	run_cmd cd ~/wayland
	run_cmd ./autogen.sh --prefix=$WLD --disable-documentation
	run_cmd make
	run_cmd make install
}

# ------
# Weston
# ------

do_weston() {
	display_action "Weston building"
	display_source "http://wayland.freedesktop.org/raspberrypi.html"

	run_cmd cd ~/
	run_cmd get_from_git "${HOME}" "git://anongit.freedesktop.org/wayland" "weston"

	run_cmd cd ~/weston
	run_cmd ./autogen.sh --prefix=$WLD \
		--disable-x11-compositor --disable-drm-compositor \
			--disable-wayland-compositor \
				--enable-weston-launch --disable-simple-egl-clients --disable-egl \
					--disable-libunwind --disable-colord --disable-resize-optimization \
						--disable-xwayland-test --with-cairo=image \
							WESTON_NATIVE_BACKEND="rpi-backend.so"

	run_cmd make
	run_cmd sudo make install

	run_cmd sudo addgroup weston-launch
	run_cmd sudo adduser pi weston-launch
}

# -------
# Armbian
# -------

do_armbian() {
	display_action "armbian building"
	display_source "http://www.armbian.com"

	run_cmd mkdir ~/armbian
	run_cmd cd ~/armbian
	run_cmd get_from_git "${HOME}" "https://github.com/igorpecovnik" "lib"
	run_cmd cp lib/compile.sh .
	run_cmd chmod +x compile.sh
	run_cmd ./compile.sh
}

# ------
# DietPi
# ------

do_dietpi() {
	display_action "install dietpi"
	display_source "http://dietpi.com"

	run_cmd cd ~/
	run_cmd get_from_git "${HOME}" "https://github.com/Fourdee" "DietPi"

}

# --------------
# qemu_raspberry
# --------------

do_qemu_raspberry() {
	display_action "emulate raspberry pi"
	display_source "http://royvanrijn.com/blog/2014/06/raspberry-pi-emulation-on-os-x/"

	qemu_dir=/Volumes/Ankh/OsiriS/qemu
	if [ ! -d ${qemu_dir} ]; then
		mkdir -p ${qemu_dir}
	fi
	cd ${qemu_dir}
	
	curl -OL http://xecdesign.com/downloads/linux-qemu/kernel-qemu
	# run_cmd curl -o raspbian_latest.zip -L http://downloads.raspberrypi.org/raspbian_lite_latest
	# run_cmd unzip raspbian_latest.zip
	# run_cmd mv 20* raspbian_latest.img
	if [ ! -e "raspbian_latest.img" ]; then
		cp /Volumes/Ankh/OsiriS/20* raspbian_latest.img
	fi

	qemu-system-arm -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw init=/bin/bash" -hda raspbian_latest.img

	# sed -i -e 's/^/#/' /etc/ld.so.preload
	# touch /etc/udev/rules.d/90-qemu.rules
	# echo 'KERNEL=="sda", SYMLINK+="mmcblk0"' >> /etc/udev/rules.d/90-qemu.rules
	# echo 'KERNEL=="sda?", SYMLINK+="mmcblk0p%n"' >> /etc/udev/rules.d/90-qemu.rules
	# echo 'KERNEL=="sda2", SYMLINK+="root"' >> /etc/udev/rules.d/90-qemu.rules
	# exit

	qemu-system-arm -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb -no-reboot -serial stdio -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" -hda raspbian_latest.img -redir tcp:5022::22
}

# -------------------------------------------------------------------------------------------------------------------------------------------------

SYSTEM=`uname -s`
DISTRIBUTION=`cat /etc/*-release | grep DISTRIB_ID | sed 's/DISTRIB_ID=//' | sed 's/"//g'`
DESCRIPTION=`cat /etc/*-release | grep DISTRIB_DESCRIPTION | sed 's/DISTRIB_DESCRIPTION=//' | sed 's/"//g'`
CODENAME=`cat /etc/*-release | grep DISTRIB_CODENAME | sed 's/DISTRIB_CODENAME=//' | sed 's/"//g'`
HOST=`echo "$HOSTNAME" | tr '[:upper:]' '[:lower:]'`

clear

display_title "OsiriS builder on ${DESCRIPTION}"

display_debug "-> main ($#): $*"

if [ $SYSTEM = "Darwin" ]; then
	action=false
fi

i=0
while [ $# -ne 0 ]
do
	arg=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	shift
	((i += 1 ))
	display_debug "parameter($i): $arg"
	case "$arg" in
		--clean)
		clean=true
		;;
		--debug)
		debug=true
		;;
		--nodebug)
		debug=false
		;;
		--action)
		action=true
		;;
		--noaction)
		action=false
		;;
		--verbose)
		verbose=true
		;;
		--quiet)
		verbose=false
		;;
		--nolog)
		nolog=true
		;;
		--log)
		nolog=false
		;;

		--platform|--darwin)
		if [ $SYSTEM = "Darwin" ]; then
			LIST_ACTIONS=( ${LIST_ACTIONS} "darwin_setup" )
		fi
		;;
	
		--raspberry)
		LIST_ACTIONS=( ${LIST_ACTIONS} "jessie_setup" "hdmipi_setup" "raspberry_tools" )
		;;
	
		--u-boot|--ardupilot|--wayland|--weston|--armbian|--qemu_raspberry)
		LIST_ACTIONS=( ${LIST_ACTIONS} "${arg:2}" )
		;;

		--kernel|--rt_kernel)
		LIST_ACTIONS=( ${LIST_ACTIONS} "linux_${arg:2}" )
		;;

		*)
		;;
	esac
done

if [ $debug = true ]; then
	display_debug "Sytem:"
	display_debug "  system:         $SYSTEM"
	display_debug "  distribution:   $DISTRIBUTION"
	display_debug "  description:    $DESCRIPTION"
	display_debug "  host:           $HOST"
	display_debug "  home:           $HOME"
	display_debug "Options:"
	display_debug "  clean:          $clean"
	display_debug "  debug:          $debug"
	display_debug "  download:       $download"
	display_debug "  action:         $action"
	display_debug "  verbose:        $verbose"
	display_debug "  nolog:          $nolog"
	display_debug "Actions"
	display_debug "  $LIST_ACTIONS"
fi

if [ $action = false ]; then
	clean=false
	debug=true
	download=false
	verbose=true
	action=false
	display_debug "force to do nothing"
fi

for ACTION in ${LIST_ACTIONS[@]}
do
	EXIST=`type -t do_${ACTION} | grep function | wc -l`
	if [ $EXIST -ne 1 ]; then
		display_error "function do_${ACTION} does not exist"
	else
		do_${ACTION}
	fi
done

echo ""
echo "####################################################################################################################################"
echo "# complete"
echo "####################################################################################################################################"
echo ""

cd ~/
