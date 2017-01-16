#!/bin/bash

clear

source functions.#!/bin/sh

debug=false
noaction=true
ask=true

log=""
logfile="/dev/null"

# ----------------------------------------------------------------------------------------------------------------------------------------------------

PACKAGE_COMMAND="not_set"
PACKAGES=( )

# ----------------------------------------------------------------------------------------------------------------------------------------------------

SDCARD="not_defined"

# ----------------------------------------------------------------------------------------------------------------------------------------------------

BUILD_LOCATION=/does_not_exist
SOURCE_LOCATION=/does_not_exist

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# setup the host platform
# ----------------------------------------------------------------------------------------------------------------------------------------------------

setup_platform () {

	display_debug "-> $FUNCNAME $*"

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "Check platform ${HOST} ..."

	case ${HOST} in
        "lburais-m-407n")
            ;;
		"vizier")
			;;
		"ra.local")
			;;
		*)
			display_fail "Well... not able to setup the $host machine for now"
			return 1
			;;
	esac

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "Installing directories ..."

	display_debug "-> $FUNCNAME $*"

	if [ ! -d "${BUILD_LOCATION}" ]; then
		display_fail "Please mount external hard drive first to be able to access $1"
		display_debug "<- $FUNCNAME"
		exit 1
	else
		display_debug "Root drive: ${BUILD_LOCATION}"
	fi

	LOCATIONS=( "${BUILD_DIR}" "${SOURCE_DIR}" "${OUTPUT_DIR}" "${WORKING_DIR}" "${TOOLS_DIR}" )
	for l in "${LOCATIONS[@]}"
	do
		setup_folder $l ${clean}
		if [ $?  -ne 0 ]; then
			display_fail "Unable to setup root $l"
			display_debug "<- $FUNCNAME"
			return 1
		fi
	done

	display_success "Directories are set up"

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "Installing pre specifics ..."

	if [ "${SYSTEM}" = "Darwin" ]; then
		display_debug "${SYSTEM} specific"
        if [ $PACKAGE_COMMAND = "brew" ]; then
            display_action "Homebrew"
            EXIST=`type -t brew | wc -l`
            if [ $EXIST -ne 1 ]; then
                ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
            fi
            EXIST=`type -t brew | wc -l`
            if [ $EXIST -eq 1 ]; then
                display_success "  set"
            else
                display_error "  missing"
                display_debug "<- $FUNCNAME"
                return 1
            fi
        else
            if [ $PACKAGE_COMMAND = "port" ]; then
                display_error "Please install MacPort from https://www.macports.org/install.php"
                display_debug "<- $FUNCNAME"
                return 1
            else
                display_debug "no pacakage manager"
            fi
		fi
	fi

	if [ "${DISTRIBUTION}" = "elementary OS" ]; then
		display_debug "${DISTRIBUTION} specific"
	fi

	if [ "${DISTRIBUTION}" = "Ubuntu" ]; then
		if [ "${CODENAME}" = "utopic" ]; then
			display_debug "${DISTRIBUTION} (${CODENAME}) specific"
			if [ ! -e /usr/lib/libpython2.7.so.1 ]; then run_cmd sudo ln -s /usr/lib/x86_64-linux-gnu/libpython2.7.so.1 /usr/lib/libpython2.7.so.1; fi
			if [ ! -e /usr/lib/libpython2.7.so.1.0 ]; then run_cmd sudo ln -s /usr/lib/libpython2.7.so.1 /usr/lib/libpython2.7.so.1.0; fi
			run_cmd gsettings set org.gnome.desktop.background show-desktop-icons false
			run_cmd xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search
		else
			display_debug "other ${DISTRIBUTION} specific"
		fi
	fi

	#display_debug "install Synology CloudStation"
	#the_package="synology-cloud-station"
	#the_release="3317"
	#full_package="${the_package}-${the_release}.deb"
	#src_package="http://global.download.synology.com/download/Tools/CloudStation/${the_release}/Linux/x64/"
	#install_manual_package

	display_success "Pre specifics are installed"

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "Installing dependencies ..."

	if [ "${SYSTEM}" = "Darwin" ]; then
		display_debug "${DISTRIBUTION} specific"
        #PACKAGES=( "libusb" "git" "autoconf" ${PACKAGES[@]} )
	fi

	if [ "${DISTRIBUTION}" = "elementary OS" ]; then
		display_debug "${DISTRIBUTION} specific"
		PACKAGES=( "minicom" "dconf-tools" ${PACKAGES[@]} )
		PACKAGES=( "indicator-usb" ${PACKAGES[@]} )
		PACKAGES=( "elementary-tweaks" ${PACKAGES[@]} )
		PACKAGES=( "elementary-wallpaper-collection" "elementary-.*-theme" "elementary-.*-icons" "indicator-synapse" ${PACKAGES[@]} )
	fi

	if [ "${DISTRIBUTION}" = "Ubuntu" ]; then
		if [ "${CODENAME}" = "utopic" ]; then
			display_debug "${DISTRIBUTION} (${CODENAME}) specific"
			PACKAGES=( "minicom" "dconf-tools" ${PACKAGES[@]} )
			PACKAGES=( "unity-tweak-tool" ${PACKAGES[@]} )
			PACKAGES=( "y-ppa-manager" ${PACKAGES[@]} )
			PACKAGES=( "nemo" ${PACKAGES[@]} )
			PACKAGES=( "ubuntu-make" ${PACKAGES[@]} )
			#PACKAGES=( "nemo-fileroller" "nemo-compare" "nemo-dropbox" "nemo-media-columns" "nemo-pastebin" ${PACKAGES[@]} )
			#PACKAGES=( "nemo-seahorse" "nemo-share" "nemo-emblems" "nemo-image-converter" ${PACKAGES[@]} )
			#PACKAGES=( "grive" ${PACKAGES[@]} )
			#PACKAGES=( "nemo-terminal" ${PACKAGES[@]} )
			#PACKAGES=( "dockbarx" "dockbarx-themes-extra" ${PACKAGES[@]} )
			PACKAGES=( "classicmenu-indicator" ${PACKAGES[@]} )
			#PACKAGES=( "ubuntu-emulator" ${PACKAGES[@]} )
			PACKAGES=( "mbuntu-y-ithemes-v4" "mbuntu-y-icons-v4" "mbuntu-y-docky-skins-v4" "mbuntu-y-bscreen-v4" ${PACKAGES[@]} )
			PACKAGES=( "mbuntu-y-lightdm-v4" "slingscold" "indicator-synapse" "docky "${PACKAGES[@]} )
		else
			display_debug "other ${DISTRIBUTION} specific"
		fi
	fi

	if [ ${#PACKAGES[@]} -gt 0 ]; then
		install_packages PACKAGES[@]
		if [ $? -ne 0 ]; then
			display_fail "Unable to install dependencies"
			display_debug "<- $FUNCNAME"
			return 1
		fi
	fi

	display_success "Dependencies are installed"

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "SSH setup ..."

	#run_cmd sudo ssh-keygen -N "" -f "~/.ssh/id_rsa.pub"
	#run_cmd cat "~/.ssh/id_rsa.pub"

	display_success "SSH is setup"

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "Installing post specifics ..."

	if [ "${DISTRIBUTION}" = "Ubuntu" ]; then
		if [ "${CODENAME}" = "utopic" ]; then
			display_debug "${DISTRIBUTION} (${CODENAME}) specific"
			#cd
			#wget -O config.sh http://drive.noobslab.com/data/Mac-14.10/config.sh
			#chmod +x config.sh
			#./config.sh
		else
			display_debug "other ${DISTRIBUTION} specific"
		fi
	fi

	display_success "Post specifics are installed"

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "Cleaning up ..."

	clean_packages

	if [ -e /usr/lib/lightdm/lightdm-set-defaults ]; then
		display_debug "disabling guest"
		run_cmd sudo /usr/lib/lightdm/lightdm-set-defaults -l false
	fi

	display_success "System configured and cleaned up"

	display_debug "<- $FUNCNAME"
	return 0
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# DO GOLDEN CHEETAH
# ----------------------------------------------------------------------------------------------------------------------------------------------------

do_golden_cheetah () {

return 0

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# MAIN
# ----------------------------------------------------------------------------------------------------------------------------------------------------

SYSTEM=`uname -s`
DISTRIBUTION=`cat /etc/*-release | grep DISTRIB_ID | sed 's/DISTRIB_ID=//' | sed 's/"//g'`
DESCRIPTION=`cat /etc/*-release | grep DISTRIB_DESCRIPTION | sed 's/DISTRIB_DESCRIPTION=//' | sed 's/"//g'`
CODENAME=`cat /etc/*-release | grep DISTRIB_CODENAME | sed 's/DISTRIB_CODENAME=//' | sed 's/"//g'`
HOST=`echo "$HOSTNAME" | tr '[:upper:]' '[:lower:]'`

clear

display_title "OsiriS builder on ${DESCRIPTION}"

display_debug "-> main ($#): $*"

i=0
while [ $# -ne 0 ]
do
	arg=`echo "$1" | tr '[:upper:]' '[:lower:]'`
	shift
	((i += 1 ))
	display_debug "parameter($i): $arg"
	case "$arg" in
		--silent)
		ask=false
		;;
		--debug)
		debug=true
		;;
		--nodebug)
		debug=false
		;;
		--noaction)
		noaction=true
		debug=true
		;;
		--action)
		shift
		((i += 1 ))
		action=$arg
		;;
		*)
		;;
	esac
done

if [ $noaction = true ]; then
	debug=true
	display_debug "no action"
fi

set_flags

EXIST=`type -t do_${action} | grep function | wc -l`
if [ $EXIST -ne 1 ]; then
	display_error "function build_${action} does not exist"
else
	do_${ID}
fi
