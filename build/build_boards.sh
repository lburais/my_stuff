#!/bin/bash

clear

source functions.#!/bin/sh



clean=false
debug=false
force=false
ask=false
nothing=false
sensitive=false


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
# ARM Linux
# ----------------------------------------------------------------------------------------------------------------------------------------------------

build_arm_linux () {

	display_title "${PLATFORM} - ${SOFTWARE}"

	display_debug "ArchLinux on OlinuXino A20: https://alarma20.wordpress.com"
	display_debug "qemu on Odroid U3: http://odroid.us/mediawiki/index.php?title=Step-by-step_Using_qemu_to_Boot_an_Emulated_Odroid"
	display_debug "Ubuntu on Odroid U3: http://forum.odroid.com/viewtopic.php?f=52&t=3662"
	display_debug "Tizen on Odroid U3: http://www.tizenexperts.com/2014/12/developer-the-testing-begins-tizen-common-on-odroid-u3/"
	display_debug "Tizen on OlinuXino A20: http://www.tizenexperts.com/2014/09/updated-tizen-common-image-for-a20-olinuxino-micro-and-other-sunxi-devices/"
	display_debug "Tizen on qemu: http://www.tizenexperts.com/2014/07/tizen-common-wayland-for-arm-on-qemu-or-device/"

	mounted=false

	DST_DIR=""
	SRC_SITE=""
	SRC_FILE=""
	SRC_GIT=""
	SRC_BRANCH=""

	PACKAGES=( )

	PACKAGES=( "libncurses-dev" ${PACKAGES[@]} )
	PACKAGES=( "gcc-arm-linux-gnueabihf" ${PACKAGES[@]} )
	PACKAGES=( "u-boot-tools" ${PACKAGES[@]} )
	PACKAGES=( "qemu" ${PACKAGES[@]} )

	case ${SOFTWAREID} in
		"tizen")
			PACKAGES=( "dfu-util" "flex" "bison" "sdb" "gbs" "mic" ${PACKAGES[@]} )
			;;
		"yocto")
			PACKAGES=("build-essential" "git" "diffstat" "gawk" "chrpath" "texinfo" "libtool" ${PACKAGES[@]} )
			;;
		*)
			;;
	esac

	setup_platform
	if [ $? -ne 0 ]; then
		display_debug "<- $FUNCNAME"
		return 1
	fi

	if [ ! -e /usr/lib/i386-linux-gnu/libGL.so -a -e /usr/lib/i386-linux-gnu/mesa/libGL.so.1 ]; then
		display_debug "make link to libGL.so"
		run_cmd sudo ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
	fi

	case ${SOFTWAREID} in
		"tizen")
			# install Lthor
			the_package="lthor"
			the_release="1.4_amd64"
			full_package="${the_package}_${the_release}.deb"
			src_package="http://download.tizen.org/tools/latest-release/Ubuntu_14.10/amd64"
			install_manual_package

			SRC_SITE="http://download.tizen.org/releases/system"
			SRC_FILE="Tizen_RD-ODROID-U3-PartMigration.tar.gz"
			get_file
			if [ $? -ne 0 ]; then
				display_debug "unable to load Odroid U3 Tizen bootloader for EMMC"
			fi

			SRC_SITE="http://download.tizen.org/releases/system"
			SRC_FILE="Tizen_RD-ODROID-U3-BootloaderForSD.tar.gz"
			get_file
			if [ $? -ne 0 ]; then
				display_debug "unable to load Odroid U3 Tizen bootloader for SDCard"
			fi

			display_debug "Loading Odroid U3 Tizen boot image"
			SRC_SITE="http://download.tizen.org/snapshots/tizen/common/latest/images/arm-x11/common-boot-armv7l-odroidu3"
			SRC_FILE="tizen-common_20150116.1_common-boot-armv7l-odroidu3.tar.gz"
			get_file
			if [ $? -ne 0 ]; then
				display_debug "unable to load Odroid U3 Tizen boot image"
			fi
			;;
		*)
			;;
	esac

	case ${PLATFORMID} in
		"odroid_u3")
			SRC_SITE="odroid.in/guides/ubuntu-lfs"
			SRC_FILE="boot.tar.gz"
			get_file
			if [ $? -ne 0 ]; then
				display_debug "unable to load Odroid U3 pre-built bootloaders"
			fi
			;;
		*)
			;;
	esac

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "Setup minicom"

	#minicom -s
	run_cmd sudo usermod -a -G dialout laurent

	display_success "minicom set"

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "Setup git user"

	run_cmd git config --global user.email laurent@burais.fr
	run_cmd git config --global user.name lburais

	display_success "git user set"

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	# GET BOOTLOADER
	# ------------------------------------------------------------------------------------------------------------------------------------------------

	DST_FOLDER=""
	SRC_GIT=""
	SRC_SITE=""
	SRC_FILE=""
	SRC_BRANCH=""
	bootloader=false
	todo=false
	case "${ID}" in
		"any_platform_u-boot"|"odroid_u3_kernel"|"odroid_u3_ubuntu"|"odroid_u3_linaro")
			SRC_FILE="u-boot"
			SRC_GIT="http://git.denx.de"
			DST_FOLDER="${BUILD_DIR}/u-boot"
			todo=true
			;;
		"odroid_u3_tizen")
			SRC_FILE="u-boot"
			SRC_GIT="ssh://lburais@review.tizen.org:29418/platform/kernel"
			SRC_BRANCH="tizen"
			DST_FOLDER="${BUILD_DIR}/u-boot"
			todo=true
			;;
		"odroid_u3_archlinux")
			SRC_SITE="http://os.archlinuxarm.org/armv7h/alarm"
			SRC_FILE="uboot-odroid-2014.10-1-armv7h.pkg.tar.xz"
			DST_FOLDER="${WORKING_DIR}/uboot-odroid-2014.10-1-armv7h.pkg/boot"
			todo=true
			;;
		"olinuxino_a20_u-boot")
			SRC_FILE="u-boot-sunxi"
			SRC_GIT="http://git.denx.de"
			DST_FOLDER="${BUILD_DIR}/u-boot"
			todo=true
			;;
		"olinuxino_a20_archlinux")
			SRC_SITE="http://os.archlinuxarm.org/armv7h/alarm"
			SRC_FILE="uboot-a20-olinuxino-micro-2014.04-10-armv7h.pkg.tar.xz"
			DST_FOLDER="${WORKING_DIR}/uboot-a20-olinuxino-micro-2014.04-10-armv7h.pkg/boot"
			todo=true
			;;
		*)
			;;
	esac

	if [ $todo = true ]; then
		display_action "Download U-Boot bootloader"
		get_file
		if [ $? -ne 0 ]; then
			display_fail "Unable to download bootloader"
		else
			display_success "Bootloader downloaded"
			bootloader=true
		fi
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	# GET KERNEL
	# ------------------------------------------------------------------------------------------------------------------------------------------------

	SRC_FILE=""
	SRC_SITE=""
	SRC_GIT=""
	SRC_BRANCH=""
	LINUX_DIR=""
	linux=false
	todo=false
	case ${ID} in
		"odroid_u3_kernel")
			SRC_FILE="linux"
			SRC_GIT="https://github.com/torvalds"
			SRC_BRANCH=""
			todo=true
			;;
		"odroid_u3_linaro"|"odroid_u3_ubuntu")
			SRC_FILE="linux"
			SRC_GIT="https://github.com/hardkernel"
			SRC_BRANCH="odroid-3.8.y"
			todo=true
			;;
		"odroid_u3_android")
			SRC_FILE="linux"
			SRC_GIT="https://github.com/hardkernel"
			SRC_BRANCH="odroid-3.0.y-android"
			todo=true
			;;
		"odroid_u3_tizen")
			SRC_FILE="linux-3.10"
			SRC_GIT="ssh://lburais@review.tizen.org:29418/platform/kernel"
			SRC_BRANCH="tizen"
			todo=true
			;;
		"olinuxino_a20_ubuntu")
			SRC_FILE="linux-sunxi"
			SRC_GIT="https://github.com/linux-sunxi"
			SRC_BRANCH="sunxi-3.4"
			todo=true
			;;
		*)
			SRC_FILE=""
			;;
	esac

	if [ $todo = true ]; then
		display_action "Download linux kernel"
		LINUX_DIR="${BUILD_DIR}/${SRC_FILE}"
		get_file
		if [ $? -ne 0 ]; then
			display_fail "cannot download kernel"
		else
			display_success "kernel downloaded"
			linux=true
		fi
	else
		display_success "no kernel to download"
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	# GET YOCTO
	# ------------------------------------------------------------------------------------------------------------------------------------------------

	SRC_FILE=""
	SRC_SITE=""
	SRC_GIT=""
	SRC_BRANCH=""
	yocto=false
	todo=false
	case ${ID} in
		"intel_edison_yocto")
			SRC_SITE="http://downloadmirror.intel.com/24389/eng/"
			SRC_FILE="edison-src-rel1-maint-rel1-ww42-14.tgz"
			todo=true
			;;
		*)
			;;
	esac
	if [ $todo = true ]; then
		display_action "Download yocto"
		get_file
		if [ $? -ne 0 ]; then
			display_fail "unable to download Yocto"
		else
			display_success "Yocto downloaded"
			yocto=true
		fi
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	# GET AND PATCH ROBOPEAK
	# ------------------------------------------------------------------------------------------------------------------------------------------------

	if [ $linux = true ]; then
		display_action "Download RoboPeak"

		SRC_FILE="rpusbdisp"
		SRC_GIT="https://github.com/robopeak"
		get_file
		if [ $? -ne 0 -o ! -d ${BUILD_DIR}/rpusbdisp ]; then
			display_fail "Unable to download RoboPeak"
		else
			display_success "RoboPeak downloaded"
			display_action "Patch RoboPeak"
			if [ -d "${LINUX_DIR}/drivers/video/rpusbdisp" -a $clean = true ]; then
				display_debug "removing rpusbdisp"
				run_cmd rm -Rf "${LINUX_DIR}/drivers/video/rpusbdisp"
			fi

			if [ ! -d "${LINUX_DIR}/drivers/video/rpusbdisp" ]; then
				display_debug "copying rpusbdisp"
				run_cmd cp -Rf "${BUILD_DIR}/rpusbdisp/drivers/linux-driver" "${LINUX_DIR}/drivers/video/rpusbdisp"
				run_cmd cp -Rf "${LINUX_DIR}/drivers/video/rpusbdisp/NewMakefile" "${LINUX_DIR}/drivers/video/rpusbdisp/Makefile"
				display_debug "fixing rpusbdisp"
				if [ ! -d "${LINUX_DIR}/drivers/video/rpusbdisp/src/inc/inc" ]; then
					mkdir "${LINUX_DIR}/drivers/video/rpusbdisp/src/inc/inc"
				fi
				cd "${LINUX_DIR}/drivers/video/rpusbdisp/src/inc"
				run_cmd cp -f *.h inc/
				cd "${BUILD_DIR}/rpusbdisp/drivers/common/inc"
				run_cmd cp -f *.h "${LINUX_DIR}/drivers/video/rpusbdisp/src/inc/inc"
			fi

			INSTALLED=`cat "${LINUX_DIR}/drivers/video/rpusbdisp/Kconfig" | grep FB_MODE_HELPERS | wc -l`
			if [ $INSTALLED -ne 1 ]; then
				display_debug "fixing HELPERS in rpusbdisp Kconfig"
				run_cmd cp -f "${LINUX_DIR}/drivers/video/rpusbdisp/Kconfig" "${LINUX_DIR}/drivers/video/rpusbdisp/Kconfig.old"
				sed -e "s/FB_MODE_HELPER/FB_MODE_HELPERS/" "${LINUX_DIR}/drivers/video/rpusbdisp/Kconfig.old" > "${LINUX_DIR}/drivers/video/rpusbdisp/Kconfig"
				run_cmd rm -f "${LINUX_DIR}/drivers/video/rpusbdisp/Kconfig.old"
			fi

			INSTALLED=`cat "${LINUX_DIR}/drivers/video/Kconfig" | grep rpusbdisp | wc -l`
			if [ $INSTALLED -ne 1 ]; then
				display_debug "adding rpusbdisp to Kconfig"
				run_cmd cp -f "${LINUX_DIR}/drivers/video/Kconfig" "${LINUX_DIR}/drivers/video/Kconfig.old"
				sed -e "/exynos\/Kconfig\"/a\\source \"drivers\/video\/rpusbdisp\/Kconfig\"" "${LINUX_DIR}/drivers/video/Kconfig.old" > "${LINUX_DIR}/drivers/video/Kconfig"
				run_cmd rm -f "${LINUX_DIR}/drivers/video/Kconfig.old"
				display_debug "adding default m in rpusbdisp/Kconfig"
				run_cmd cp -f "${LINUX_DIR}/drivers/video/rpusbdisp/Kconfig" "${LINUX_DIR}/drivers/video/rpusbdisp/Kconfig.old"
				sed -e "/tristate \"Robopeak USB Display\"/a\\default m" "${LINUX_DIR}/drivers/video/rpusbdisp/Kconfig.old" > "${LINUX_DIR}/drivers/video/rpusbdisp/Kconfig"
				run_cmd rm -f "${LINUX_DIR}/drivers/video/rpusbdisp/Kconfig.old"
			fi

			INSTALLED=`cat "${LINUX_DIR}/drivers/video/Makefile" | grep RPUSBDISP | wc -l`
			if [ $INSTALLED -ne 1 ]; then
				display_debug "adding rpusbdisp to Makefile"
				run_cmd cp -f "${LINUX_DIR}/drivers/video/Makefile" "${LINUX_DIR}/drivers/video/Makefile.old"
				sed -e "/+= exynos\//a\\obj-\$(CONFIG_FB_RPUSBDISP) += rpusbdisp\/" "${LINUX_DIR}/drivers/video/Makefile.old" > "${LINUX_DIR}/drivers/video/Makefile"
			fi
			display_success "Kernel patched for RoboPeak"
		fi
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	# GET MALI DRIVER
	# ------------------------------------------------------------------------------------------------------------------------------------------------

	if [ $linux = true -a false = true ]; then
		display_debug "Mali Linux Kernel Device Driver"
		SRC_SITE="http://malideveloper.arm.com/downloads/drivers/DX910/r5p0-01rel0"
		SRC_FILE="DX910-SW-99002-r5p0-01rel0.tgz"
		#get_from_web
		if [ $? -ne 0 ]; then
			display_debug "<- $FUNCNAME"
			return 1
		fi

		if [ "${ID}" = "odroid_u3_ubuntu" ]; then
			display_debug "Mali Linux Kernel Device Driver"
			SRC_SITE="http://builder.mdrjr.net/tools"
			SRC_FILE="mali.txz"
			#get_from_web
			if [ $? -ne 0 ]; then
				display_debug "<- $FUNCNAME"
				return 1
			fi
		fi
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	# GET ROOTFS
	# ------------------------------------------------------------------------------------------------------------------------------------------------

	SRC_FILE=""
	SRC_SITE=""
	SRC_GIT=""
	SRC_BRANCH=""
	DST_FOLDER=""
	rootfs=false
	todo=false
	case ${SOFTWAREID} in
		"linaro")
			linaro="developer" # nano or developer or gnome
			linaro_build="20141212-693"
			linaro_release="14.12"
			SRC_SITE="http://releases.linaro.org/$inaro_release/ubuntu/utopic-images/$linaro"
			SRC_FILE="linaro-utopic-$linaro-$inaro_build.tar.gz"
			DST_FOLDER="binary"
			todo=true
			;;
		"archlinux")
			case ${PLATFORMID} in
				"odroid_u3")
					SRC_SITE="http://os.archlinuxarm.org/os/exynos/"
					SRC_FILE="ArchLinuxARM-2015.01-odroid-u2-rootfs.tar.gz"
					DST_FOLDER="extract"
					todo=true
					;;
				*)
					;;
			esac
			;;
		"tizen")
			case ${PLATFORMID} in
				"odroid_u3")
					SRC_SITE="http://download.tizen.org/snapshots/tizen/common/latest/images/arm-wayland/common-wayland-3parts-armv7l-odroidu3"
					SRC_FILE="tizen-common_20150116.1_common-wayland-3parts-armv7l-odroidu3.tar.gz"
					DST_FOLDER="extract"
					todo=true
					;;
				*)
					;;
			esac
			;;
		*)
			;;
	esac

	if [ $todo = true ]; then
		get_file
		if [ $? -ne 0 ]; then
			display_fail "Unable to download rootfs"
		else
			display_debug "rootfs downloaded"
			if [ -e "${WORKING_DIR}/${DST_FOLDER}" ]; then
				if [ -e "${WORKING_DIR}/rootfs" ]; then
					run_cmd sudo rm -fr "${WORKING_DIR}/rootfs"
				fi
				run_cmd mv "${WORKING_DIR}/${DST_FOLDER}" "${WORKING_DIR}/rootfs"
				rootfs=true
			else
				display_fail "Cannot find ${DST_FOLDER} folder"
			fi
		fi
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	# BUILD BOOTLOADER
	# ------------------------------------------------------------------------------------------------------------------------------------------------

	def=""
	uboot=false
	todo=false
	case ${ID} in
		"odroid_u3_kernel"|"odroid_u3_ubuntu"|"odroid_u3_linaro")
			def="odroid_defconfig"
			todo=true
			;;
		"odroid_u3_tizen")
			def="tizen_config"
			todo=true
			;;
		*)
			;;
	esac

	if [ $todo = true ]; then
		if [ ${SOFTWAREID} = "tizen"  -a -d ${BUILD_DIR}/u-boot/tools/dtc ]; then
			display_action "Build Device Tree Compiler"
			cd ${BUILD_DIR}/u-boot/tools/dtc
			run_cmd make install
			if [ $? -ne 0 ]; then
				display_fail "Cannot build Device Tree Compiler"
			else
				display_success "Device Tree Compiler built"
			fi
		fi

		cd ${BUILD_DIR}/u-boot
		display_action "Configure u-boot"
		run_cmd make ${make_flags} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- ${def}
		if [ $? -ne 0 ]; then
			display_fail "Cannot configure u-boot"
		else
			display_success "u-boot configured"
			display_action "Compile u-boot"
			run_cmd make ${make_flags} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4
			if [ $? -ne 0 ]; then
				display_fail "Cannot compile u-boot"
			else
				display_debug "u-boot make completed"
				if [ -e "u-boot.bin" -a ${SOFTWAREID} = "tizen" ]; then
					display_debug "addind DTB"
					run_cmd ./tools/mkimage_multidtb.sh u-boot.bin
					if [ $? -ne 0 ]; then
						display_fail "Cannot append DTB"
					else
						display_debug "DTB append to u-boot"
						if [ -e "u-boot-multi.bin" ]; then
							display_debug "signing platform"
							run_cmd ./tools/mkimage_signed.sh u-boot-multi.bin tizen_config
							if [ $? -ne 0 -o ! -e ${BUILD_DIR}/u-boot/u-boot-mmc.bin ]; then
								display_fail "Cannot sign platform"
							else
								run_cmd mv ${BUILD_DIR}/u-boot/u-boot-mmc.bin ${OUTPUT_DIR}
								display_success "u-boot compiled and signed as u-boot-mmc.bin"
							fi
						else
							display_success "no u-boot to sign"
						fi
					fi
				else
					display_success "no DTB to append"
				fi
				uboot=true
			fi
		fi
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	# BUILD KERNEL
	# ------------------------------------------------------------------------------------------------------------------------------------------------

	def=""
	todo=false
	if [ $linux = true ]; then
		case ${PLATFORMID} in
			"odroid_u3")
				case ${SOFTWAREID} in
					"kernel")
						def="exynos_defconfig"
						;;
					"archlinux")
						def="odroidu_ubuntu_defconfig"
						;;
					"ubuntu")
						def="odroidu_defconfig"
						;;
					"android")
						def="odroidu_android_442_defconfig"
						;;
					"tizen")
						def="tizen_odroid_defconfig"
						;;
					*)
						;;
				esac
				;;
			"olinuxino_a20")
				display_debug "download A20_defconfig"
				SRC_SITE="https://raw.github.com/hehopmajieh/OLinuXino-A20/master"
				SRC_FILE="olinuxinoA20-3.4_defconfig"
				get_file
				if [ $? -eq 0 ]; then
					if [ -e "${SOURCE_DIR}/olinuxinoA20-3.4_defconfig" ]; then
						display_debug "install A20_defconfig"
						run_cmd cp -f "${SOURCE_DIR}/olinuxinoA20-3.4_defconfig" "${LINUX_DIR}/arch/arm/configs/olinuxinoA20_defconfig"
					fi
					def="olinuxinoA20_defconfig"
				fi
				;;
			*)
				;;
		esac

		if [ "x${def}" != "x" ]; then
			todo=true
		fi

		kernel=false
		if [ $todo = true ]; then
			cd ${LINUX_DIR}
			display_action "Configure kernel"
			run_cmd make ${make_flags} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- ${def}
			if [ $? -ne 0 ]; then
				display_fail "Cannot configure kernel"
			else
				display_success "Kernel configured"
				display_action "Compile kernel"
				run_cmd make ${make_flags} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4
				if [ $? -ne 0 ]; then
					display_fail "Cannot compile kernel"
				else
					display_success "Kernel compiled"
					display_action "Compile modules"
					setup_folder ${WORKING_DIR}/modules $clean
					run_cmd sudo make ${make_flags} ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- INSTALL_MOD_PATH=${WORKING_DIR}/modules modules_install
					if [ $? -ne 0 ]; then
						display_fail "Cannot compile modules"
					else
						display_success "Modules compiled"
						if [ -e ${LINUX_DIR}/arch/arm/boot/zImage ]; then
							display_success "Kernel built"
							kernel=true
						else
							display_fail "Cannot find kernel image"
						fi
					fi
				fi
			fi
		fi
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	# BUILD YOCTO
	# ------------------------------------------------------------------------------------------------------------------------------------------------

	SRC_FOLDER=""
	todo=false
	if [ $yocto = true ]; then
		case ${PLATFORMID} in
			"intel_edison")
				case ${SOFTWAREID} in
					"yocto")
						SRC_FOLDER="edison-src"
						todo=true
						;;
					*)
						;;
				esac
				;;
			*)
				;;
		esac
		if [ $todo = true ]; then
			display_action "Building Yocto"
			cd "${WORKING_DIR}/${SRC_FOLDER}"
			run_cmd ./device-software/setup.sh
			if [ $? -ne 0 ]; then
				display_fail "Cannot setup yocto"
			else
				display_debug "source poky/oe-init-build-env"
				source poky/oe-init-build-env >> $logfile 2>&1
				if [ $? -ne 0 ]; then
					display_fail "Cannot dource yocto"
				else
					bitbake edison-image
					if [ $? -ne 0 ]; then
						display_fail "Cannot bitbake yocto"
					else
						run_cmd ../device-software/utils/flash/postBuild.sh
						if [ $? -ne 0 ]; then
							display_fail "Cannot post build yocto"
						else
							display_success "Yocto built"
						fi
					fi
				fi
			fi
		fi
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	# QEMU
	# ------------------------------------------------------------------------------------------------------------------------------------------------

	# qemu will be true if qemu properly setup
	qemu=false

	if [ "${PLATFORMID}" = "xqemu" ]; then
		display_action "Setup qemu"
		display_debug "Create qemu partitions"
		if [ -e ${OUTPUT_DIR}/${ID}_boot.img ]; then run_cmd rm -f ${OUTPUT_DIR}/${ID}_boot.img; fi
		if [ -e ${OUTPUT_DIR}/${ID}_rootfs.img ]; then run_cmd rm -f ${OUTPUT_DIR}/${ID}_rootfs.img; fi
		run_cmd qemu-img create "${OUTPUT_DIR}/${ID}_boot.img" 64M
		run_cmd qemu-img create "${OUTPUT_DIR}/${ID}_rootfs.img" 2048M
		run_cmd sudo mkfs.vfat -v -n BOOT "${OUTPUT_DIR}/${ID}_boot.img"
		run_cmd sudo mkfs.ext4 -F -L rootfs "${OUTPUT_DIR}/${ID}_rootfs.img"

		display_debug "Mount qemu partitions"
		if [ -d "${WORKING_DIR}/loop" ]; then run_cmd sudo rm -fr "${WORKING_DIR}/loop"; fi
		run_cmd mkdir -p "${WORKING_DIR}/loop/boot"
		run_cmd mkdir -p "${WORKING_DIR}/loop/rootfs"
		if [ ! -d "${WORKING_DIR}/loop/boot" -a ! -d "${WORKING_DIR}/loop/rootfs" ]; then
			display_fail "unable to create partitions"
		else
		    run_cmd sudo mount -o loop  "${OUTPUT_DIR}/${ID}_boot.img" ${WORKING_DIR}/loop/boot
			INSTALLED=`mount | grep "${OUTPUT_DIR}/${ID}_boot.img" | wc -l`
			if [ $INSTALLED -ne 1 ]; then
				display_fail "Boot partition not mounted"
			else
				run_cmd sudo mount -o loop "${OUTPUT_DIR}/${ID}_rootfs.img" ${WORKING_DIR}/loop/rootfs
				INSTALLED=`mount | grep "${OUTPUT_DIR}/${ID}_rootfs.img" | wc -l`
				if [ $INSTALLED -ne 1 ]; then
					display_fail "Rootfs partition not mounted"
					run_cmd sudo umount "${OUTPUT_DIR}/${ID}_boot.img"
				else
					display_success "Partitions mounted"
					qemu=true
				fi
			fi
			if [ $qemu = false -a -d ${WORKING_DIR}/loop ]; then run_cmd rm -fr ${WORKING_DIR}/loop; fi
		fi
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "Transfer rootfs"

	if [ -e "${WORKING_DIR}/rootfs" -a $qemu = true ]; then
		display_debug "Transfer rootfs"
		run_cmd sudo cp -Rf "${WORKING_DIR}/rootfs/*" "${WORKING_DIR}/loop/rootfs"
		if [ $? -ne 0 ]; then
			display_fail "Cannot transfer rootfs "
		else
			display_success "rootfs transferred"
		fi
	else
		display_success "No rootfs transfer"
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "Transfer kernel modules"

	if [ $kernel = true -a $qemu = true ]; then
		cd ${WORKING_DIR}/modules
		run_cmd sudo cp -Rf . ${WORKING_DIR}/loop/rootfs
		if [ $? -ne 0 ]; then
			display_fail "Cannot install modules"
		else
			display_success "Kernel modules transferred"
		fi
	else
		display_success "No kernel modules transfer"
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "Transfer and setup kernel"

	if [ $kernel = true -a $qemu = true ]; then
		display_debug "Install kernel"
		run_cmd sudo cp ${LINUX_DIR}/arch/arm/boot/zImage ${WORKING_DIR}/loop/boot
		if [ $? -ne 0 ]; then
			display_fail "Cannot transfer kernel"
		else
			display_debug "Install boot script"
			echo "setenv initrd_high \"0xffffffff\"" > ${WORKING_DIR}/boot.txt
			echo "setenv fdt_high \"0xffffffff\"" >> ${WORKING_DIR}/boot.txt
			echo "setenv bootcmd \"fatload mmc 0:1 0x40008000 zImage; bootm 0x40008000\"" >> ${WORKING_DIR}/boot.txt
			echo "setenv bootargs \"console=tty1 console=ttySAC1,115200n8 root=/dev/mmcblk0p2 rootwait rw mem=2047M\"" >> ${WORKING_DIR}/boot.txt
			echo "boot" >> ${WORKING_DIR}/boot.txt
			if [ -e ${WORKING_DIR}/loop/boot/boot.txt ]; then run_cmd sudo rm -f ${WORKING_DIR}/loop/boot/boot.txt; fi
			run_cmd sudo mv ${WORKING_DIR}/boot.txt ${WORKING_DIR}/loop/boot
			#cd ${WORKING_DIR}/loop/boot
			run_cmd sudo mkimage -A arm -T script -C none -n boot -d ${WORKING_DIR}/loop/boot/boot.txt ${WORKING_DIR}/loop/boot/boot.scr
			errcode=$?
			#cd ${BUILD_DIR}
			if [ $? -ne 0 ]; then
				display_fail "Cannot install boot script"
			else
				display_success "Kernel transferred"
			fi
		fi
	else
		display_success "No kernel transfer"
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "Configurations"

	setup_folder "${OUTPUT_DIR}/config" $update # force clean if update
	if [ $? -ne 0 ]; then
		display_fail "Cannot create ${OUTPUT_DIR}/config"
	else

		display_debug "Configure network card"
		run_cmd mkdir -p "${OUTPUT_DIR}/config/etc/network/interfaces.d"
		echo "auto eth0" > "${OUTPUT_DIR}/config/etc/network/interfaces.d/eth0"
		echo "iface eth0 inet dhcp" >> "${OUTPUT_DIR}/config/etc/network/interfaces.d/eth0"

		display_debug "Configure fstab"
		run_cmd mkdir -p "${OUTPUT_DIR}/config/etc"
		#mount -t devtmpfs devtmpfs /dev
		if [ $qemu = true -a -e "${WORKING_DIR}/loop/rootfs/etc/fstab" ]; then
			run_cmd cp "${WORKING_DIR}/loop/rootfs/etc/fstab" "${OUTPUT_DIR}/config/etc/fstab"
		fi
		echo "UUID=e139ce78-9841-40fe-8823-96a304a09859 / ext4  errors=remount-ro,noatime 0 1" >> "${OUTPUT_DIR}/config/etc/fstab"
		echo "/dev/mmcblk0p1 /media/boot vfat defaults,rw,owner,flush,umask=000 0 0" >> "${OUTPUT_DIR}/config/etc/fstab"
		echo "tmpfs /tmp tmpfs nodev,nosuid,mode=1777 0 0" >> "${OUTPUT_DIR}/config/etc/fstab"

	fi

	if [ $qemu = true ]; then
		display_debug "copy config folder"
		run_cmd sudo cp -fr "${OUTPUT_DIR}/config" "${WORKING_DIR}/loop/rootfs"
		if [ $? -ne 0 ]; then
			display_fail "Cannot transfer configuration"
		else
			display_success "Configuration transferred"
		fi
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "qemu clean up"

	if [ $qemu = true ]; then
		display_debug "Unmount partition"
		run_cmd sudo umount "${OUTPUT_DIR}/${ID}_boot.img"
		run_cmd sudo umount "${OUTPUT_DIR}/${ID}_rootfs.img"
		if [ -d "${WORKING_DIR}/loop" ]; then run_cmd sudo rm -fr "${WORKING_DIR}/loop"; fi

		INSTALLED=$(which qemulator | wc -l)
		if [ $INSTALLED -eq 0 ]; then
			display_debug "Downloading Qemulator"
			SRC_SITE="http://virtualbricks.eu/phocadownload"
			SRC_FILE="qemulator-0.5.tar.gz"
			get_from_web
			if [ $? -ne 0 ]; then
				display_debug "unable to download Qemulator"
			else
				display_debug "installing Qemulator"
				run_cmd cd "${WORKING_DIR}/Qemulator-0.5"
				run_cmd sudo ./setup.sh
				if [ $? -ne 0 ]; then
					display_debug "unable to install Qemulator"
				else
					display_debug "Qemulator installed"
				fi
			fi
		else
			display_debug "Qemulator already installed"
		fi

		display_debug "qemu examples"
		SRC_SITE="http://odroid.us/odroid/users/osterluk/qemu-example"
		SRC_FILE="qemu-example.tgz"
		#get_from_web
		if [ $? -ne 0 ]; then
			display_debug "<- $FUNCNAME"
			return 1
		fi

		display_debug "qemu launch script"
		if [ -e ${OUTPUT_DIR}/${ID}.sh ]; then
			rm -f ${OUTPUT_DIR}/${ID}.sh
		fi
		if [ -e "${BUILD_DIR}/../../qemu/Linux/linux-linaro-stable/arch/arm/boot/zImage" ]; then
			echo "#! /bin/sh" >> ${OUTPUT_DIR}/${ID}.sh
			echo "export ROOTFS=${OUTPUT_DIR}/${ID}_rootfs.img" >> ${OUTPUT_DIR}/${ID}.sh
			echo "export NETWORK=\"-net nic -net user\"" >> ${OUTPUT_DIR}/${ID}.sh
			echo "export KERNEL=\"${BUILD_DIR}\/..\/..\/qemu\/Linux\/linux-linaro-stable\/arch\/arm\/boot\/zImage\"" >> ${OUTPUT_DIR}/${ID}.sh
			echo "" >> ${OUTPUT_DIR}/${PLATFORMID}_${SOFTWAREID}.sh
			echo "qemu-system-arm -append \"root=/dev/mmcblk0 rw physmap.enabled=0 console=ttyAMA0\" -M vexpress-a9 \$KERNEL -sd \$ROOTFS  \$NETWORK -nographic" >> ${OUTPUT_DIR}/${ID}.sh
			run_cmd chmod +x ${OUTPUT_DIR}/${ID}.sh
		fi
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------

	mounted=false # will be true if sdcard is properly setup

	display_action "Cleaning SDCard"
	INSTALLED=`lsblk | grep $SDCARD | grep disk | grep " 1 " | wc -l`
	if [ $INSTALLED -ne 1 ]; then
		display_fail "Disk $SDCARD is missing"
	else
		if [ $force = true ]; then
			display_debug "Emptying the card /dev/$SDCARD"
			run_cmd sudo dd if=/dev/zero of=/dev/$SDCARD bs=1M
			display_success "Card /dev/$SDCARD emptied"
		else
			list=( "1" "2" "3" "4")
			display_debug "Erasing the card /dev/$SDCARD"
			if [ -e /tmp/part ]; then
				run_cmd rm -f /tmp/part
			fi
			for i in ${list[@]}
			do
				INSTALLED=`lsblk | grep $SDCARD$i | wc -l`
				if [ $INSTALLED -eq 1 ]; then
					echo "d" >> /tmp/part		# delete
					echo $i >> /tmp/part		# partition
				fi
				INSTALLED=`mount | grep $SDCARD$i | wc -l`
				if [ $INSTALLED -eq 1 ]; then
					run_cmd sudo umount /dev/$SDCARD$i
				fi
			done
			if [ -e /tmp/part ]; then
				sed -i '$ d' /tmp/part
				echo "w" >> /tmp/part		# write
				sudo fdisk /dev/$SDCARD < /tmp/part >> $logfile 2>&1
				run_cmd sudo partprobe
				rm -f /tmp/part
			fi
			display_success "Card /dev/$SDCARD erased"
		fi
	fi

	case ${PLATFORMID} in
		"odroid_u3")
			display_action "Fusing Odroid U3 bootloader on /dev/$SDCARD"
			INSTALLED=`lsblk | grep $SDCARD | grep disk | grep " 1 " | wc -l`
			if [ $INSTALLED -ne 1 ]; then
				display_error "Disk $SDCARD is missing"
			else
				cd ${WORKING_DIR}/boot
				if [ -e E4412_S.bl1.HardKernel.bin -a -e E4412_S.tzsw.signed.bin -a -e bl2.signed.bin -a -e ${BUILD_DIR}/u-boot/u-boot-dtb.bin ]; then
					signed_bl1_position=1
					bl2_position=31
					uboot_position=63
					tzsw_position=2111
					cont=true

					if [ $cont = true ]; then
						display_debug "BL1 fusing"
						run_cmd sudo dd iflag=dsync oflag=dsync if=./E4412_S.bl1.HardKernel.bin of=/dev/$SDCARD seek=$signed_bl1_position
						if [ $? -ne 0 ]; then
							display_fail "Cannot fuse E4412_S.bl1.HardKernel.bin on /dev/$SDCARD"
							cont=false
						fi
					fi

					if [ $cont = true ]; then
						display_debug "BL2 fusing"
						run_cmd sudo dd iflag=dsync oflag=dsync if=./bl2.signed.bin of=/dev/$SDCARD seek=$bl2_position
						if [ $? -ne 0 ]; then
							display_fail "Cannot fuse bl2.signed.bin on /dev/$SDCARD"
							cont=false
						fi
					fi

					if [ $cont = true ]; then
						display_debug "u-boot fusing"
						run_cmd sudo dd iflag=dsync oflag=dsync if=${BUILD_DIR}/u-boot/u-boot-dtb.bin of=/dev/$SDCARD seek=$uboot_position
						if [ $? -ne 0 ]; then
							display_fail "Cannot fuse ${BUILD_DIR}/u-boot/u-boot-dtb.bin on /dev/$SDCARD"
							cont=false
						fi
					fi

					if [ $cont = true ]; then
						display_debug "TrustZone S/W fusing"
						run_cmd sudo dd iflag=dsync oflag=dsync if=./E4412_S.tzsw.signed.bin of=/dev/$SDCARD seek=$tzsw_position
						if [ $? -ne 0 ]; then
							display_fail "Cannot fuse E4412_S.tzsw.signed.bin on /dev/$SDCARD"
							cont=false
						else
							display_success "Odroid U3 bootloader fused on /dev/$SDCARD"
						fi
					fi
				else
					display_fail "Missing files to fuse on /dev/$SDCARD"
				fi
			fi
			;;
		*)
			;;
	esac

	display_action "Partitioning /dev/$SDCARD"
	INSTALLED=`lsblk | grep $SDCARD | grep disk | grep " 1 " | wc -l`
	if [ $INSTALLED -ne 1 ]; then
		display_fail "Disk $SDCARD is missing"
	else
		if [ -e ${WORKING_DIR}/partitions ]; then
			run_cmd rm -fr ${WORKING_DIR}/partitions
		fi
		case ${PLATFORMID} in
			"odroid_u3")
				echo "n" >> ${WORKING_DIR}/partitions		# new
				echo "p" >> ${WORKING_DIR}/partitions		# partition
				echo "1" >> ${WORKING_DIR}/partitions		# partition 1
				echo "3072" >> ${WORKING_DIR}/partitions	# start address
				echo "+64M" >> ${WORKING_DIR}/partitions	# size
				echo "n" >> ${WORKING_DIR}/partitions		# new
				echo "p" >> ${WORKING_DIR}/partitions		# partition
				echo "2" >> ${WORKING_DIR}/partitions		# partition 2
				echo "135168" >> ${WORKING_DIR}/partitions	# start address (right after partition 1)
				echo "" >> ${WORKING_DIR}/partitions		# default size (all remaining)
				echo "t" >> ${WORKING_DIR}/partitions		# type
				echo "1" >> ${WORKING_DIR}/partitions		# partition 1
				echo "c" >> ${WORKING_DIR}/partitions		# Fat32
				echo "w" >> ${WORKING_DIR}/partitions		# write
				;;
			*)
				;;
		esac
		cat ${WORKING_DIR}/partitions
		if [ -e ${WORKING_DIR}/partitions ]; then
			sudo fdisk /dev/$SDCARD < ${WORKING_DIR}/partitions >> $logfile 2>&1
			if [ $? -ne 0 ]; then
				display_fail "Unable to partition /dev/$SDCARD"
			else
				run_cmd sudo partprobe
				if [ $? -ne 0 ]; then
					display_fail "Unable to probe /dev/$SDCARD"
				else
					display_success "/dev/$SDCARD partitionned"
				fi
			fi
		else
			display_fail "No partitioning instructions"
		fi
	fi

	display_action "Formatting /dev/$SDCARD"
	INSTALLED=`lsblk | grep $SDCARD | grep disk | grep " 1 " | wc -l`
	if [ $INSTALLED -ne 1 ]; then
		display_fail "Disk $SDCARD is missing"
	else
		case ${PLATFORMID} in
			"odroid_u3")
				run_cmd sudo mkfs.vfat -q -n BOOT /dev/$SDCARD"1"
				if [ $? -ne 0 ]; then
					display_fail "Unable to format /dev/$SDCARD1"
				fi
				run_cmd sudo mkfs.ext4 -q -F -L rootfs /dev/$SDCARD"2"
				if [ $? -ne 0 ]; then
					display_fail "Unable to format /dev/$SDCARD2"
				fi
				run_cmd sudo tune2fs /dev/$SDCARD"2" -U e139ce78-9841-40fe-8823-96a304a09859
				run_cmd sudo tune2fs -O ^has_journal /dev/$SDCARD"2"

				display_debug "Mount partitions from /dev/$SDCARD"
				run_cmd mkdir -p ${WORKING_DIR}/sdcard/rootfs
				run_cmd mkdir -p ${WORKING_DIR}/sdcard/boot
	    		run_cmd sudo mount --rw /dev/$SDCARD"1" ${WORKING_DIR}/sdcard/boot
				INSTALLED=`mount | grep $SDCARD"1" | wc -l`
				if [ $INSTALLED -ne 1 ]; then
					display_error "Partition 1 on $SDCARD not mounted"
				else
					run_cmd sudo mount --rw /dev/$SDCARD"2" ${WORKING_DIR}/sdcard/rootfs
					INSTALLED=`mount | grep $SDCARD"2" | wc -l`
					if [ $INSTALLED -ne 1 ]; then
						display_error "Partition 2 on $SDCARD not mounted"
						run_cmd sudo umount /dev/$SDCARD"1"
					else
						display_success "Partitions mounted on $SDCARD"
						mounted=true
					fi
				fi
				if [ $mounted = false -a -d ${WORKING_DIR}/sdcard ]; then
					run_cmd rm -fr ${WORKING_DIR}/sdcard
				fi
				;;
			*)
				display_success "No action required on $SDCARD"
				;;
		esac
	fi

	if [ $mounted = true ]; then
		display_action "Transfer boot on /dev/$SDCARD"
	fi

	if [ $mounted = true ]; then
		display_action "Transfer rootfs on /dev/$SDCARD"
	fi

	if [ $mounted = true ]; then
		display_debug "Unmount /dev/$SDCARD and clean up"
		cd ${BUILD_DIR}
		list=( "1" "2" "3" "4")
		for i in ${list[@]}
		do
			INSTALLED=`mount | grep $SDCARD$i | wc -l`
			if [ $INSTALLED -eq 1 ]; then
				run_cmd sudo umount /dev/$SDCARD$i
			fi
		done
		run_cmd sync
		run_cmd sudo rm -fr ${WORKING_DIR}/sdcard
	fi

	return 0
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# Vizier
# ----------------------------------------------------------------------------------------------------------------------------------------------------

build_vizier_platform() { setup_platform; }

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# Ra
# ----------------------------------------------------------------------------------------------------------------------------------------------------

build_ra_platform () { setup_platform; }

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# Builds
# ----------------------------------------------------------------------------------------------------------------------------------------------------

build_olinuxino_a20_ubuntu () { build_arm_linux; }
build_olinuxino_a20_tizen () { build_arm_linux; }
build_olinuxino_a20_u-boot () { build_arm_linux; }

build_odroid_u3_ubuntu () { build_arm_linux; }
build_odroid_u3_linaro () { build_arm_linux; }
build_odroid_u3_tizen () { build_arm_linux; }
build_odroid_u3_kernel () { build_arm_linux; }
build_odroid_u3_archlinux () { build_arm_linux; }

build_qemu_linux () { build_arm_linux; }

build_intel_edison_yocto () { build_arm_linux; }

build_any_platform_u-boot () { build_arm_linux; }

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# Odroid U3 Android
# ----------------------------------------------------------------------------------------------------------------------------------------------------

build_odroid_u3_android () {

	display_title "${PLATFORM} - ${SOFTWARE}"

	SRC_SITE=""
	SRC_FILE=""
	SRC_GIT=""

	PACKAGES=( )

	# Ubuntu 14.10
	if [ $CODENAME = "utopic" ]; then
		display_debug "remove installed java"
		sudo apt-get -qq purge openjdk-\* icedtea-\* icedtea6-\*
		PACKAGES=( ${PACKAGES[@]} "git" "gnupg" "ccache" "lzop" "flex" "bison" "gperf" "build-essential" "zip" "curl" "zlib1g-dev" "zlib1g-dev:i386" )
		PACKAGES=( ${PACKAGES[@]} "libc6-dev" "lib32bz2-1.0" "lib32ncurses5-dev" "x11proto-core-dev" "libx11-dev:i386" "libreadline6-dev:i386" )
		PACKAGES=( ${PACKAGES[@]} "lib32z1-dev" "libgl1-mesa-glx:i386" "libgl1-mesa-dev" "g++-multilib" "mingw32" "tofrodos" "python-markdown" )
		PACKAGES=( ${PACKAGES[@]} "libxml2-utils" "xsltproc" "libreadline6-dev" "lib32readline-gplv2-dev" "libncurses5-dev" "bzip2" "libbz2-dev" )
		PACKAGES=( ${PACKAGES[@]} "libbz2-1.0" "libghc-bzlib-dev" "lib32bz2-dev" "squashfs-tools" "pngcrush" "schedtool" "dpkg-dev" )
	else
		PACKAGES=( ${PACKAGES[@]} "bison" "g++-multilib" "git" "gperf" "libxml2-utils" )
		PACKAGES=( ${PACKAGES[@]} "bison" "git" "gperf" "libxml2-utils" "python-software-properties" )
		PACKAGES=( ${PACKAGES[@]} "libncurses-dev" )
	fi

	PACKAGES=( ${PACKAGES[@]} "gcc-arm-linux-gnueabihf")
	PACKAGES=( ${PACKAGES[@]} "oracle-java6-installer" )
	PACKAGES=( ${PACKAGES[@]} "android-tools-adb" "android-tools-fastboot" )

	setup_vizier_platform
	if [ $? -ne 0 ]; then
		display_debug "<- $FUNCNAME"
		return 1
	fi

	if [ ! -e /usr/lib/i386-linux-gnu/libGL.so -a -e /usr/lib/i386-linux-gnu/mesa/libGL.so.1 ]; then
		display_debug "make link to libGL.so"
		sudo ln -s /usr/lib/i386-linux-gnu/mesa/libGL.so.1 /usr/lib/i386-linux-gnu/libGL.so
	fi

	if [ ! -e /etc/udev/rules.d/51-android.rules ]; then
		display_debug "set android rules for adb"
		echo "SUBSYSTEM==\"usb\", ATTR{idVendor}==\"18d1\", MODE=\"0666\", GROUP=\"plugdev\"" > /tmp/51-android.rules
		sudo cp /tmp/51-android.rules /etc/udev/rules.d/51-android.rules
		rm /tmp/51-android.rules
		sudo chmod 666 /etc/udev/rules.d/51-android.rules
		sudo chown root /etc/udev/rules.d/51-android.rules
		sudo service udev restart
		sudo killall adb
		adb devices
	fi

	display_debug "Force make 3.81"
	the_package="make"
	the_release="3.81-8.2ubuntu3_amd64"
	full_package="${the_package}_${the_release}.deb"
	src_package="http://launchpadlibrarian.net/141976501"
	install_manual_package

	display_action "Setup minicom"
	#minicom -s
	sudo usermod -a -G dialout laurent

	display_action "Setup user"
	git config --global user.email laurent@burais.fr
	git config --global user.name lburais

	display_action "Download linux kernel"

	SRC_FILE="linux"
	SRC_GIT="https://github.com/hardkernel"
	SRC_BRANCH="odroid-3.0.y-android"

	get_from_git
	if [ $? -ne 0 ]; then
		display_debug "<- $FUNCNAME"
		return 1
	fi

	display_action "Download and install RoboPeak"

	SRC_FILE="rpusbdisp"
	SRC_GIT="https://github.com/robopeak"
	SRC_BRANCH=""

	get_from_git
	if [ $? -ne 0 ]; then
		display_debug "<- $FUNCNAME"
		return 1
	fi

	if [ -d "${BUILD_DIR}/linux/drivers/video/rpusbdisp" -a $clean = true ]; then
		display_debug "removing rpusbdisp"
		rm -Rf "${BUILD_DIR}/linux/drivers/video/rpusbdisp"
	fi

	if [ ! -d "${BUILD_DIR}/linux/drivers/video/rpusbdisp" -o $update = true ]; then
		display_debug "copying rpusbdisp"
		cp -Rf "${BUILD_DIR}/rpusbdisp/drivers/linux-driver" "${BUILD_DIR}/linux/drivers/video/rpusbdisp"
		cp -Rf "${BUILD_DIR}/linux/drivers/video/rpusbdisp/NewMakefile" "${BUILD_DIR}/linux/drivers/video/rpusbdisp/Makefile"
		display_debug "fixing rpusbdisp"
		if [ ! -d "${BUILD_DIR}/linux/drivers/video/rpusbdisp/src/inc/inc" ]; then
			mkdir "${BUILD_DIR}/linux/drivers/video/rpusbdisp/src/inc/inc"
		fi
		cd "${BUILD_DIR}/linux/drivers/video/rpusbdisp/src/inc"
		cp -f *.h inc/
		cd "${BUILD_DIR}/rpusbdisp/drivers/common/inc"
		cp -f *.h "${BUILD_DIR}/linux/drivers/video/rpusbdisp/src/inc/inc"
	fi

	INSTALLED=`cat "${BUILD_DIR}/linux/drivers/video/rpusbdisp/Kconfig" | grep FB_MODE_HELPERS | wc -l`
	if [ $INSTALLED -ne 1 ]; then
		display_debug "fixing HELPERS in rpusbdisp Kconfig"
		cp -f "${BUILD_DIR}/linux/drivers/video/rpusbdisp/Kconfig" "${BUILD_DIR}/linux/drivers/video/rpusbdisp/Kconfig.old"
		sed -e "s/FB_MODE_HELPER/FB_MODE_HELPERS/" "${BUILD_DIR}/linux/drivers/video/rpusbdisp/Kconfig.old" > "${BUILD_DIR}/linux/drivers/video/rpusbdisp/Kconfig"
		rm -f "${BUILD_DIR}/linux/drivers/video/rpusbdisp/Kconfig.old"
	fi

	INSTALLED=`cat "${BUILD_DIR}/linux/drivers/video/Kconfig" | grep rpusbdisp | wc -l`
	if [ $INSTALLED -ne 1 ]; then
		display_debug "adding rpusbdisp to Kconfig"
		cp -f "${BUILD_DIR}/linux/drivers/video/Kconfig" "${BUILD_DIR}/linux/drivers/video/Kconfig.old"
		sed -e "/samsung\/Kconfig\"/a\\source \"drivers\/video\/rpusbdisp\/Kconfig\"" "${BUILD_DIR}/linux/drivers/video/Kconfig.old" > "${BUILD_DIR}/linux/drivers/video/Kconfig"
		rm -f "${BUILD_DIR}/linux/drivers/video/Kconfig.old"
		display_debug "adding default m in rpusbdisp/Kconfig"
		cp -f "${BUILD_DIR}/linux/drivers/video/rpusbdisp/Kconfig" "${BUILD_DIR}/linux/drivers/video/rpusbdisp/Kconfig.old"
		sed -e "/tristate \"Robopeak USB Display\"/a\\default m" "${BUILD_DIR}/linux/drivers/video/rpusbdisp/Kconfig.old" > "${BUILD_DIR}/linux/drivers/video/rpusbdisp/Kconfig"
		rm -f "${BUILD_DIR}/linux/drivers/video/rpusbdisp/Kconfig.old"
	fi

	INSTALLED=`cat "${BUILD_DIR}/linux/drivers/video/Makefile" | grep RPUSBDISP | wc -l`
	if [ $INSTALLED -ne 1 ]; then
		display_debug "adding rpusbdisp to Makefile"
		cp -f "${BUILD_DIR}/linux/drivers/video/Makefile" "${BUILD_DIR}/linux/drivers/video/Makefile.old"
		sed -e "/+= samsung\//a\\obj-\$(CONFIG_FB_RPUSBDISP) += rpusbdisp\/" "${BUILD_DIR}/linux/drivers/video/Makefile.old" > "${BUILD_DIR}/linux/drivers/video/Makefile"
	fi

	display_action "Build kernel"
	if [ $build =  true -a -d ${BUILD_DIR}/linux ]; then
		cd ${BUILD_DIR}/linux
		make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- odroidu_android_442_defconfig
		make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4
	fi

	display_action "Build rpusbdisp usermode"
	if [ $build =  true -a -d ${BUILD_DIR}/rpusbdisp/drivers/usermode-sdk ]; then
		cd ${BUILD_DIR}/rpusbdisp/drivers/usermode-sdk
			display_debug "fixing rpusbdisp"
			if [ ! -d "${BUILD_DIR}/linux/drivers/video/rpusbdisp/src/inc/inc" ]; then
				mkdir "${BUILD_DIR}/linux/drivers/video/rpusbdisp/src/inc/inc"
			fi
			cd "${BUILD_DIR}/linux/drivers/video/rpusbdisp/src/inc"
			cp -f *.h inc/
			cd "${BUILD_DIR}/rpusbdisp/drivers/common/inc"
			cp -f *.h "${BUILD_DIR}/linux/drivers/video/rpusbdisp/src/inc/inc"
			display_debug "building rpusbdisp"
		make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4
	fi

	display_action "Download Android"

	PATH=~/bin:$PATH
	if [ -d ~/bin/repo -a $clean = true ]; then
		display_debug "removing repo"
		rm -fr ~/bin/repo
	fi
	if [ ! -d ~/bin ]; then
		mkdir ~/bin
	fi
	if [ $download = true -o $update = true ]; then
		display_debug "loading repo"
		curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
		sudo chmod a+x ~/bin/repo
	fi

	cd ${BUILD_DIR}
	if [ $download = true -o $update = true ]; then
		if [ -e ~/bin/repo ]; then
			display_debug "loading android"
			~/bin/repo init -u https://github.com/hardkernel/android.git -b 4412_4.4.4_master
			~/bin/repo sync
		fi
	fi

	if [ $build = true ]; then
		if [ -e build_android.sh ]; then
			display_debug "building android"
			./build_android.sh odroidu
			if [ $? -ne 0 ]; then
				display_fail "build_odroid"
				display_debug "<- $FUNCNAME"
				return 1
			fi
		fi
	fi

	CONNECTED=`adb devices | grep BABABEEFBABABEEF | wc -l`
	if [ $CONNECTED -ge 1 ]; then
		display_debug "device is connected"
		cd "${BUILD_DIR}"
		adb remount
		for module in `find . -iname *.ko`; do adb push $module /system/lib/modules ; done
		adb shell depmod
		adb shell modprobe rp_usbdisplay
		adb shell cat /proc/fb
	else
		display_fail "device not connected"
		return 1
	fi

	display_debug "<- $FUNCNAME"
	return 0;

	repo start odroid_4412_master --all
	repo forall -c git reset --hard 4412_v3.5

	./build_android.sh odroidu
	if [ $? -ne 0 ]; then
		display_fail "build_odroid"
		return 1
	fi

	return 0
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# Intel Edison Yocto
# ----------------------------------------------------------------------------------------------------------------------------------------------------

xbuild_intel_edison_yocto () {

	display_title "${PLATFORM} - ${SOFTWARE}"

	PACKAGES=("build-essential" "git" "diffstat" "gawk" "chrpath" "texinfo" "libtool" )
	#PACKAGES=("build-essential" "git" "diffstat" "gawk" "chrpath" "texinfo" "libtool" "gcc-multilib")
	setup_vizier_platform
	if [ $? -ne 0 ]; then
		return 1
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	display_action "Download yocto"

	SRC_SITE="http://downloadmirror.intel.com/24389/eng/"
	SRC_FILE="edison-src-rel1-maint-rel1-ww42-14.tgz"
	SRC_GIT=""

	get_from_web
	if [ $? -ne 0 ]; then
		display_debug "<- $FUNCNAME"
		return 1
	fi

	# ------------------------------------------------------------------------------------------------------------------------------------------------
	# build edison image
	if [ $update = true ]; then
		display_action "Building ${SOFTWARE} on ${PLATFORM} platform"
		cd "${WORKING_DIR}/edison-src"

		run_cmd ./device-software/setup.sh
		run_cmd source poky/oe-init-build-env
		run_cmd bitbake edison-image
		run_cmd ../device-software/utils/flash/postBuild.sh
	fi

	return 0
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# Carambola openWRT
# ----------------------------------------------------------------------------------------------------------------------------------------------------

build_carambola_openwrt () {

	display_title "${PLATFORM} - ${SOFTWARE}"

	SRC_SITE=""
	SRC_FILE="carambola"
	SRC_GIT="git://github.com/vyacht"

	PACKAGES=( "ncurses-dev" "gcc" "binutils" "patch" "bzip2" "flex" "make" "gettext" "pkg-config" "unzip" "libz-dev" "libc-dev")
	setup_vizier_platform
	if [ $? -ne 0 ]; then
		return 1
	fi

	# build
	if [ $update = true ]; then
		display_action "Building ${SOFTWARE} on ${PLATFORM} platform"
		cd "${BUILD_DIR}/carambola"
		./scripts/feeds update
		./scripts/feeds install
		if [ -e  "${BUILD_DIR}/carambola/package/hotplug2/Makefile" ]; then
			display_debug "changing revision for hotplug2"
			cp -f "${BUILD_DIR}/carambola/package/hotplug2/Makefile" "tmpfile"
			sed -e "s/PKG_REV:=201/PKG_REV:=4/" "tmpfile" > "${BUILD_DIR}/carambola/package/hotplug2/Makefile"
			rm -f "tmpfile"
			display_debug "changing source for hotplug2"
			cp -f "${BUILD_DIR}/carambola/package/hotplug2/Makefile" "tmpfile"
			sed -e "s/svn.nomi.cz\/svn\/isteve\/hotplug2\/hotplug2.googlecode.com\/svn\/trunk/" "tmpfile" > "${BUILD_DIR}/linux/drivers/video/rpusbdisp/Kconfig"
			rm -f "tmpfile"
		fi
		make menuconfig
		make
	fi

	return 0
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# OlinuXino A20 openWRT
# ----------------------------------------------------------------------------------------------------------------------------------------------------

build_olinuxino_a20_openwrt () {

	display_title "${PLATFORM} - ${SOFTWARE}"

	SRC_SITE=""
	SRC_FILE="openwrt"
	SRC_GIT="git://git.openwrt.org"

	PACKAGES=( "ncurses-dev" "zlib1g-dev" "subversion" "libssl-dev")
	setup_vizier_platform
	if [ $? -ne 0 ]; then
		return 1
	fi

	# build
	if [ $update = true ]; then
		display_action "Building ${SOFTWARE} on ${PLATFORM} platform"
		cd "${BUILD_DIR}/openwrt"
		make menuconfig
		make
	fi

	return 0
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# OlinuXino A20 Debian
# ----------------------------------------------------------------------------------------------------------------------------------------------------

build_olinuxino_a20_debian () {

	display_title "${PLATFORM} - ${SOFTWARE}"

	SRC_SITE=""
	SRC_FILE="openwrt"
	SRC_GIT="git://git.openwrt.org"

	PACKAGES=( "ncurses-dev" "zlib1g-dev" "subversion" "libssl-dev")
	setup_vizier_platform
	if [ $? -ne 0 ]; then
		return 1
	fi

	# build
	if [ $update = true ]; then
		display_action "Building ${SOFTWARE} on ${PLATFORM} platform"
		cd "${BUILD_DIR}/openwrt"
		make menuconfig
		make
	fi

	return 0
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# DAVE@AXON FOR OLIMEX
# ----------------------------------------------------------------------------------------------------------------------------------------------------

build_olinuxino_a20_android () {

	display_title "${PLATFORM} - ${SOFTWARE}"

	SRC_SITE=""
	SRC_FILE="openwrt"
	SRC_GIT="git://git.openwrt.org"

	PACKAGES=()
	setup_vizier_platform
	if [ $? -ne 0 ]; then
		return 1
	fi

	setup_folder ${BUILD_DIR}/lichee
	if [ $? -ne 0 ]; then
		return 1
	fi
	setup_folder ${BUILD_DIR}/android4.2
	if [ $? -ne 0 ]; then
		return 1
	fi

	#set_android_environment
	exit
	if [ $? -ne 0 ]; then
		display_fail "unable to set Android environment"
		exit 1
	fi

	cd ${BUILD_DIR}

	# check and extract tar files

	if [ ! -e ${BUILD_DIR}/lichee/README ]; then
		extract_tar_file ${BUILD_DIR}/lichee ${SOURCE1_DIR}/lichee-daveataxon.tar.gz
	fi

	if [ ! -e ${BUILD_DIR}/android4.2/Makefile ]; then
		extract_tar_file ${BUILD_DIR}/android4.2 ${SOURCE1_DIR}/android4.2-daveataxon.tar.gz
	fi

	# patching files

	FILES=""
	FILES="$FILES ${BUILD_DIR}/lichee/linux-3.4/arch/arm/configs/sun7ismp_android_defconfig"
	FILES="$FILES ${BUILD_DIR}/lichee/linux-3.4/arch/arm/mach-sun7i/core.c"
	FILES="$FILES ${BUILD_DIR}/lichee/linux-3.4/.config"
	FILES="$FILES ${BUILD_DIR}/android4.2/device/softwinner/olinuxino-a20/BoardConfig.mk"
	FILES="$FILES ${BUILD_DIR}/android4.2/device/softwinner/olinuxino-a20/olinuxino_a20.mk"
	FILES="$FILES ${BUILD_DIR}/android4.2/device/softwinner/olinuxino-a20/init.sun7.rc"
	patch_files $FILES

	if [ ! -d ${BUILD_DIR}/android4.2/device/softwinner/olunixino-a20 ]; then
		extract_tar_file ${BUILD_DIR}/android4.2/device/softwinner/ ${SOURCE1_DIR}/olinuxino-a20-daveataxon.tar
	fi

	cd ${BUILD_DIR}

	cd ${BUILD_DIR}/lichee
	display_action "-> set kernel options"
	# set in ${BUILD_DIR}/lichee/linux-3.4/arch/arm/configs/sun7ismp_android_defconfig
	# 	CONFIG_HID_SUNPLUS=m
	# 	CONFIG_USB_SERIAL_PL2303=m
	# 	CONFIG_USB_SERIAL=m
	# 	CONFIG_BT=m
	# 	CONFIG_BT_RFCOMM=m
	# 	CONFIG_BT_RFCOMM_TTY=y
	# 	CONFIG_BT_BNEP=m
	# 	CONFIG_BT_BNEP_MC_FILTER=y
	# 	CONFIG_BT_BNEP_PROTO_FILTER=y
	# 	CONFIG_BT_HIDP=m
	# 	CONFIG_BT_HCIBTUSB=m
	#	CONFIG_RTC_DRV_DS1307=m
	# set in ${BUILD_DIR}/lichee/linux-3.4/arch/arm/mach-sun7i/core.c at bottom after sw_pdev_init()
	#	i2c_register_board_info(0, __rtc_i2c_board_info, ARRAY_SIZE(__rtc_i2c_board_info));
	# set in ${BUILD_DIR}/lichee/linux-3.4/arch/arm/mach-sun7i/core.c at the top
	#	#include <linux.i2c.h>
	#	static struct i2c_board_info __rtc_i2c_board_info[] = {
	#		{
	#			I2C_BOARD_INFO("ds1307", 0x68),
	#		}
	#	};

	display_action "-> building lichee"
	./build.sh -psun7i_android 1>${IMAGE_DIR}/output_lichee_daveataxon.txt 2>&1
	if [ $? -ne 0 ]; then
		display_fail "build of lichee failed"
		tail ${IMAGE_DIR}/output_lichee_daveataxon.txt
		return 1
	fi

	FILES=""
	FILES="$FILES ${BUILD_DIR}/lichee/out/android/common/bImage"
	FILES="$FILES ${BUILD_DIR}/lichee/out/android/common/zImage"
	FILES="$FILES ${BUILD_DIR}/lichee/out/android/common/uImage"
	#FILES="$FILES ${BUILD_DIR}/lichee/out/android/common/lib/modules/3.4/*"
	FILES="$FILES ${BUILD_DIR}/lichee/out/android/common/u-boot.bin"
	for FILE in $FILES
	do
		if [ ! -e $FILE ]; then
			display_fail "missing file $FILE"
			return 1
		fi
	done

	cd ${BUILD_DIR}/android4.2
	display_action "-> set android options"
	# in ${BUILD_DIR}/android4.2/device/softwinner/olinuxino-a20/BoardConfig.mk
	# 	set BOARD_HAVE_BLUETOOTH := true
	# 	add BOARD_BLUETOOTH_BDROID_BUILDCFG_INCLUDE_DIR := device/generic/common/bluetooth
	#
	# in ${BUILD_DIR}/android4.2/device/softwinner/olinuxino-a20/olinuxino_a20.mk
	# 	uncomment bluetooth lines in section wifi & bt config file
	#
    # in ${BUILD_DIR}/android4.2/device/softwinner/olinuxino-a20/init.sun7.rc
	# 	#insmod specifics
	# 	insmod /system/vendor/modules/hid-sunplus.ko
	# 	insmod /system/vendor/modules/btusb.ko
	# 	insmod /system/vendor/modules/bnep.ko
	# 	insmod /system/vendor/modules/hidp.ko
	# 	insmod /system/vendor/modules/rfcomm.ko
	# 	insmod /system/vendor/modules/bluetooth.ko
	# 	insmod /system/vendor/modules/pl2303.ko
	# 	insmod /system/vendor/modules/usbserial.ko
	# 	insmod /system/vendor/modules/rtc-ds1307.ko

	display_action "-> building android"
	source build/envsetup.sh
	lunch      #select 15 olinuxino-a20_eng
	extract-bsp
	make -j4  1>${IMAGE_DIR}/output_android_daveataxon.txt 2>&1
	if [ $? -ne 0 ]; then
		display_fail "make of android failed"
		tail ${IMAGE_DIR}/output_android_daveataxon.txt
		return 1
	fi

	FILES=""
	FILES="$FILES out/target/product/olinuxino-a20/system.img"
	FILES="$FILES ${BUILD_DIR}/lichee/out/android/common/u-boot.bin"
	FILES="$FILES ${BUILD_DIR}/lichee/tools/pack/chips/sun7i/configs/android/olinuxino-a20/sys_config.fex"
	FILES="$FILES ${BUILD_DIR}/lichee/tools/pack/chips/sun7i/configs/android/olinuxino-a20/sys_partition.fex"
	for FILE in $FILES
	do
		if [ ! -e $FILE ]; then
			display_fail "missing file $FILE"
			return 1
		fi
	done

	display_action "packing android"

	which pack
	pack

	if [ -e ${BUILD_DIR}/lichee/tools/pack/sun7i_android_olinuxino-a20.img ]; then
		cp ${BUILD_DIR}/lichee/tools/pack/sun7i_android_olinuxino-a20.img ${IMAGE_DIR}
	else
		display_fail "missing file ${BUILD_DIR}/lichee/tools/pack/sun7i_android_olinuxino-a20.img"
		return 1
	fi

	return 0
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# OsiriS: OpenCPN, muplex
# ----------------------------------------------------------------------------------------------------------------------------------------------------

build_osiris_applications () {

	display_debug "-> build_osiris $*"

	display_title "OsiriS"

	BUILD_DIR=${BUILD_LOCATION}/Documents/OsiriS

	setup_folder ${BUILD_DIR} $do_clean
	if [ $? -ne 0 ]; then
		display_fail "setup_folder"
		return 1
	fi

	display_action "muplex"

	# install muplex dependencies
	PACKAGES=("socat")
	install_packages PACKAGES[@]
	if [ $? -ne 0 ]; then
		display_fail "install_packages"
		return 1
	fi
	cd ${BUILD_DIR}
	git clone https://github.com/lburais/muplex.git

	display_action "glshim"

	cd ${BUILD_DIR}
	git clone https://github.com/seandepagnier/glshim.git
	cd ${BUILD_DIR}/glshim
	cmake .
	make GL
	sudo cp glshim/lib/libGL.so.1 /usr/local/lib/
	sudo cp -r glshim/include/GLES/ /usr/local/include/

	display_action "glues"

	cd ${BUILD_DIR}
	git clone https://github.com/ssvb/glues.git
	cd ${BUILD_DIR}/glues
	cmake .
	make
	sudo cp libGLU.so.1 /usr/local/lib

	display_action "OpenCPN"

	# install GPS and wxWidgets dependencies
	local PACKAGES=("wx-common" "wx3.0-headers" "libwxbase3.0-dev" "libwxgtk3.0-0" "libwxgtk3.0-dev"  "gpsd" "gpsd-clients" "libgps-dev")
	install_packages PACKAGES[@]
	if [ $? -ne 0 ]; then
		display_fail "install_packages"
		return 1
	fi

	cd ${BUILD_DIR}
	git clone git://github.com/OpenCPN/OpenCPN.git
	cd ${BUILD_DIR}/OpenCPN/
	mkdir build
	cd build
	cmake ../
	make
	make install
	#opencpn

	return 0
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# Mac OSX crosstool-ng toolchain
# ----------------------------------------------------------------------------------------------------------------------------------------------------

build_mac_osx_toolchain () {
    display_debug "-> build_mac_osx_toolchain $*"

    display_title "Mac OSX toolchain"

    setup_platform
    if [ $? -ne 0 ]; then
        display_fail "missing package management"
        return 1
    fi

    CROSSTOOL_NG_DIR="${BUILD_DIR}/crosstool-ng"

    run_cmd cd "${BUILD_DIR}"

    display_action "Load crosstool-ng sources from GIT"

    PACKAGES=("autoconf" "grep" "gnu-sed" "binutils" "wget" "gawk" "libtool" "automake")
    install_packages PACKAGES[@]
    if [ $? -ne 0 ]; then
        display_fail "install_packages"
        return 1
    fi

    SRC_FILE="crosstool-ng"
    SRC_GIT="http://crosstool-ng.org/git"
    SRC_BRANCH="master"

    get_from_git
    if [ $? -ne 0 ]; then
        display_debug "<- $FUNCNAME"
        return 1
    fi

    display_debug "patch paths.sh in ${CROSSTOOL_NG_DIR}"
    FILE_TO_PATCH="Does_not_exist"
    FILE_TO_PATCH=`find ${CROSSTOOL_NG_DIR} -name paths.sh`
    if [ -e "${FILE_TO_PATCH}" ]; then
        display_debug "patching ${FILE_TO_PATCH}"
        ISOK=`cat ${FILE_TO_PATCH} | grep ggrep | wc -l`
        if [ $ISOK -ne 1 ]; then
            display_debug "${FILE_TO_PATCH}"
            sudo sed -e "s/\/usr\/bin\/grep/ggrep/" "${FILE_TO_PATCH}" > "tmpfile"
            sudo cp -f "tmpfile" "${FILE_TO_PATCH}"
            rm -f "tmpfile"
        fi
    fi

    display_debug "OSX patches"
    SRC_GIT="https://github.com/uboreas"
    SRC_FILE="ctworks"
    get_from_git
    if [ $? -ne 0 ]; then
        display_fail "unable to download patches"
    else
        display_debug "patches availabe in ${WORKING_DIR}"
    fi

    display_action "let's go and make it"

    cd "${CROSSTOOL_NG_DIR}"
    run_cmd ./bootstrap
    run_cmd ./configure --enable-local
    run_cmd make

    display_action "Configure toolchain"

    display_debug "load the default arm-unknown-linux-gnueabi configuration"
    cd "${CROSSTOOL_NG_DIR}"
    run_cmd ./ct-ng arm-unknown-linux-gnueabi

    display_debug "load Jared Wolff rpi config file"
    SRC_SITE="http://www.jaredwolff.com/toolchains"
    SRC_FILE="rpi-xtools-config-201302071302.zip"
    get_from_web
    if [ $? -ne 0 ]; then
        display_fail "unable to download Jared's config"
    else
        cp "${WORKING_DIR}/config" "${CROSSTOOL_NG_DIR}/.config"
        display_debug "installed Jared's config"
    fi

    display_debug "patch config file"
    cd "${CROSSTOOL_NG_DIR}"
    cp -f ".config" ".config.old"
    echo "s/CT_LOCAL_TARBALLS_DIR=.*/CT_LOCAL_TARBALLS_DIR=\"`echo ${CROSSTOOL_NG_DIR} | sed 's:\/:\\\/:g'`\/src\"/" > patch
    echo "s/CT_PREFIX_DIR=.*/CT_PREFIX_DIR=\"`echo ${OUTPUT_DIR} | sed 's:\/:\\\/:g'`\/\${CT_TARGET}\"/" >> patch
    echo "s/CT_WORK_DIR=.*/CT_WORK_DIR=\"`echo ${CROSSTOOL_NG_DIR} | sed 's:\/:\\\/:g'`\/.build\"/" >> patch
    echo "s/.*CT_ONLY_EXTRACT.*/CT_ONLY_EXTRACT=y/" >> patch
    echo "s/CT_PARALLEL_JOBS=.*/CT_PARALLEL_JOBS=4/" >> patch
    sed -f patch ".config.old" > ".config"
    #rm -f patch


    display_debug "download packages"
    cd "${CROSSTOOL_NG_DIR}"
    #./ct-ng help
    ./ct-ng build

    display_debug "patch Makefile.in"

    display_debug "patch eglibc"

    display_debug "patch config file"
    cd "${CROSSTOOL_NG_DIR}"
    # CT_ONLY_EXTRACT=n
    # cp -f ".config" ".config.old"
    # sed -e "s/.*CT_ONLY_EXTRACT.*/CT_ONLY_EXTRACT=n/" ".config.old" > ".config"

    run_cmd ulimit -n 1024

    display_action "Build toolchain"

}

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
        --clean)
            clean=true
            ;;
	    --debug)
	        debug=true
			;;
	    --nodebug)
	        debug=false
			;;
		--force)
			force=true
			;;
        --ask)
            ask=true
            ;;
		--nothing)
			nothing=true
			;;
        --sensitive)
            sensitive=true
            ;;


		--OsiriS)
			what=osiris
			;;
		--qemu)
			PLATFORM="qemu"
			;;
      	--odroid_u3)
			PLATFORM="Odroid U3"
            ;;
      	--olinuxino_a20)
			PLATFORM="OlinuXino A20"
            ;;
      	--cubiboard)
			PLATFORM="Cubieboard"
            ;;
      	--edison)
			PLATFORM="Intel Edison"
            ;;
        --raspberry)
            PLATFORM="Raspberry Pi 2"
            ;;
      	--carambola)
			PLATFORM="Carambola"
            ;;
      	--windows)
			PLATFORM="Microsoft Windows"
            ;;
      	--mac)
			PLATFORM="Mac OSX"
            ;;
      	--any)
			PLATFORM="Any Platform"
            ;;

      	--kernel)
			SOFTWARE="Kernel"
            ;;
      	--linux)
			SOFTWARE="Linux"
            ;;
      	--tizen)
			SOFTWARE="Tizen"
            ;;
      	--android)
			SOFTWARE="Android"
            ;;
      	--yocto)
			SOFTWARE="Yocto"
            ;;
      	--openwrt)
			SOFTWARE="openWRT"
            ;;
      	--ubuntu)
			SOFTWARE="Ubuntu"
            ;;
      	--linaro)
			SOFTWARE="Linaro"
            ;;
      	--u-boot)
			SOFTWARE="u-boot"
            ;;
      	--archlinux)
			SOFTWARE="ArchLinux"
            ;;
      	--applications)
			SOFTWARE="Applications"
            ;;
        --toolchain)
            SOFTWARE="Toolchain"
            ;;
      	--platform)
			SOFTWARE="platform"
            ;;
        *)
            ;;
    esac
done

if [ $nothing = true ]; then
	clean=false
	debug=true
	force=false
	display_debug "force to do nothing"
fi

set_flags

EXIST=`type -t build_${ID} | grep function | wc -l`
if [ $EXIST -ne 1 ]; then
	display_error "function build_${ID} does not exist"
else
	build_${ID}
fi


do_start() {

SYSTEM=`uname -s`
DISTRIBUTION=`cat /etc/*-release | grep DISTRIB_ID | sed 's/DISTRIB_ID=//' | sed 's/"//g'`
DESCRIPTION=`cat /etc/*-release | grep DISTRIB_DESCRIPTION | sed 's/DISTRIB_DESCRIPTION=//' | sed 's/"//g'`
CODENAME=`cat /etc/*-release | grep DISTRIB_CODENAME | sed 's/DISTRIB_CODENAME=//' | sed 's/"//g'`
HOST=`echo "$HOSTNAME" | tr '[:upper:]' '[:lower:]'`

clear

display_title "OsiriS builder on ${DESCRIPTION}"

display_debug "-> main ($#): $*"

BUILD_LOCATION=/does_not_exist
SOURCE_LOCATION=/does_not_exist

BUILD_DIR=/does_not_exist
SOURCE_DIR=/does_not_exist
SOURCE1_DIR=/does_not_exist
SOURCE2_DIR=/does_not_exist
OUTPUT_DIR=/does_not_exist
WORKING_DIR=/does_not_exist
TOOLS_DIR=/does_not_exist

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
		--force)
			force=true
			;;
        --ask)
            ask=true
            ;;
		--nothing)
			nothing=true
			;;
        --sensitive)
            sensitive=true
            ;;


		--OsiriS)
			what=osiris
			;;
		--qemu)
			PLATFORM="qemu"
			;;
      	--odroid_u3)
			PLATFORM="Odroid U3"
            ;;
      	--olinuxino_a20)
			PLATFORM="OlinuXino A20"
            ;;
      	--cubiboard)
			PLATFORM="Cubieboard"
            ;;
      	--edison)
			PLATFORM="Intel Edison"
            ;;
        --raspberry)
            PLATFORM="Raspberry Pi 2"
            ;;
      	--carambola)
			PLATFORM="Carambola"
            ;;
      	--windows)
			PLATFORM="Microsoft Windows"
            ;;
      	--mac)
			PLATFORM="Mac OSX"
            ;;
      	--any)
			PLATFORM="Any Platform"
            ;;

      	--kernel)
			SOFTWARE="Kernel"
            ;;
      	--linux)
			SOFTWARE="Linux"
            ;;
      	--tizen)
			SOFTWARE="Tizen"
            ;;
      	--android)
			SOFTWARE="Android"
            ;;
      	--yocto)
			SOFTWARE="Yocto"
            ;;
      	--openwrt)
			SOFTWARE="openWRT"
            ;;
      	--ubuntu)
			SOFTWARE="Ubuntu"
            ;;
      	--linaro)
			SOFTWARE="Linaro"
            ;;
      	--u-boot)
			SOFTWARE="u-boot"
            ;;
      	--archlinux)
			SOFTWARE="ArchLinux"
            ;;
      	--applications)
			SOFTWARE="Applications"
            ;;
        --toolchain)
            SOFTWARE="Toolchain"
            ;;
      	--platform)
			SOFTWARE="platform"
            ;;
        *)
            ;;
    esac
done

SDCARD=`ask_input "Name of the SDCard" "$SDCARD"`
echo "=> $SDCARD"

CHOICES=( "Odroid U3" "OlinuXino A20" "Cubieboard" "Intel Edison" "Carambola" "Raspberry Pi 2" "Mac OSX" "Microsoft Windows" "Any Platform" )
ask_list "What platform to build " PLATFORM CHOICES[@]
PLATFORM=${CHOICES[$?]]}

CHOICES=( "Kernel" "Linux" "Tizen" "Android" "Yocto" "openWRT" "Ubuntu" "Linaro" "u-boot" "ArchLinux" "Applications" "Toolchain")
ask_list "What software to build" SOFTWARE CHOICES[@]
SOFTWARE=${CHOICES[$?]]}

CHOICES=( true false )
ask_list "Case sensitive" sensitive CHOICES[@]
sensitive=${CHOICES[$?]]}

CHOICES=( true false )
ask_list "Force" force CHOICES[@]
force=${CHOICES[$?]]}

CHOICES=( true false )
ask_list "Clean" clean CHOICES[@]
clean=${CHOICES[$?]]}

#if [ $debug = true ]; then
#    logfile="/dev/stdout"
#fi

if [ $sensitive = true ]; then
    display_action "Disk files"

    LOC="Do_not_exist"
    LOCATIONS=( "/development" "/media/psf/development" "/media/laurent/Development"  "/Volumes/Ankh/OsiriS" "/Volumes/Mummy/Development" )
    for l in "${LOCATIONS[@]}"
    do
        if [ -d "$l" ]; then
            display_debug "found $l"
            LOC=$l
            break
        fi
    done

    DISKS=("osiris-5000")
    for d in "${DISKS[@]}"
    do
        name=`echo ${d} | sed 's/-.*//'`
        size=`echo ${d} | sed 's/[^-]*-//'`
        DMG="${LOC}/${name}.dmg"
        VOL="/Volumes/${name}"

        if [ ! -e "${DMG}.sparseimage" ]; then
            sudo hdiutil create -type "SPARSE" -size ${size}m -fs "Case-sensitive HFS+" -volname "${name}" ${DMG} >> "$logfile"
            if [ ! -e "${DMG}.sparseimage" ]; then
                display_fail "${DMG}.sparseimage not created"
            else
                display_success "${DMG}.sparseimage created"
            fi
        else
            display_debug "${DMG}.sparseimage already created"
        fi
        if [ -e "${DMG}.sparseimage" ]; then
            display_debug "mounting ..."
            m=$(hdiutil info | grep ${VOL} | cut -f1)
            if [ ! -z "${m}" ]; then
                run_cmd sudo hdiutil detach -force "${m}"
                if [ "${m}" != "/Volumes" ]; then
                    rm -rf "${m}"
                fi
            fi
            run_cmd sudo hdiutil attach ${DMG}.sparseimage
            ISOK=`mount | grep ${VOL} | wc -l`
            if [ $ISOK -eq 1 ]; then
                display_debug "${VOL} is mounted"
            else
                display_fail "${VOL} is not mounted"
                return 1
            fi
        fi
    done
fi

case $SYSTEM in
    "Linux"|"Darwin")
        LOCATIONS=( "/development" "/media/psf/development" "/media/laurent/Development"  "/Volumes/osiris" "/Volumes/Mummy/Development/Build" )
        for l in "${LOCATIONS[@]}"
        do
            if [ -d "$l" ]; then
                display_debug "found $l"
                BUILD_LOCATION=$l
                break
            fi
        done
        LOCATIONS=( "/media/psf/OsiriS" "/Volumes/Ankh/OsiriS" )
        for l in "${LOCATIONS[@]}"
        do
            if [ -d "$l" ]; then
                display_debug "found $l"
                SOURCE_LOCATION=$l
                break
            fi
        done
        ;;
    *)
        display_fail "Non supported system (${system}) for now"
        exit 1
        ;;
esac

EXIST=`type -t brew | wc -l`
if [ $EXIST -eq 1 ]; then PACKAGE_COMMAND="brew"; fi
EXIST=`type -t port | wc -l`
if [ $EXIST -eq 1 ]; then PACKAGE_COMMAND="port"; fi
EXIST=`type -t apt-get | wc -l`
if [ $EXIST -eq 1 ]; then PACKAGE_COMMAND="apt-get"; fi

if [ -d ${BUILD_DIR} ]; then
        logfile="${BUILD_DIR}/${PLATFORMID}_${SOFTWAREID}.txt"
        if [ -e "$logfile" ]; then
            rm -fr "$logfile"
        fi
    else
        logfile="/dev/null"
fi

PLATFORMID=`echo "${PLATFORM}" | sed 's/ /_/g' | tr '[:upper:]' '[:lower:]'`
SOFTWAREID=`echo "${SOFTWARE}" | sed 's/ /_/g' | tr '[:upper:]' '[:lower:]'`
ID="${PLATFORMID}_${SOFTWAREID}"

TOOLS_DIR=${BUILD_LOCATION}/tools

if [ -n "${PLATFORM}" -a -n "${SOFTWARE}" ]; then
	BUILD_DIR="${BUILD_LOCATION}/${PLATFORM}/${SOFTWARE}"
	SOURCE1_DIR="${SOURCE_LOCATION}/Hardware/${PLATFORM}/sources"
	SOURCE2_DIR="${SOURCE_LOCATION}/Software/${SOFTWARE}/sources"

	BUILD_DIR=`echo "${BUILD_DIR}" | sed 's/ /_/g'`
	OUTPUT_DIR="$BUILD_DIR/output"
	WORKING_DIR="$BUILD_DIR/working"
	SOURCE_DIR="$BUILD_DIR/sources"
fi

if [ -d ${BUILD_DIR} ]; then
    logfile="${BUILD_DIR}/${PLATFORMID}_${SOFTWAREID}.txt"
    if [ -e "$logfile" ]; then
        rm -fr "$logfile"
    fi
else
    logfile="/dev/null"
fi

set_flags

if [ $debug = true ]; then
	display_debug "Options:"
	display_debug "  clean:          $clean"
	display_debug "  debug:          $debug"
	display_debug "  force:          $force"
  display_debug "  nothing:        $nothing"
  display_debug "  sensitive:      $sensitive"
	display_debug "Variables:"
	display_debug "  system:         $SYSTEM"
	display_debug "  distro:         $DISTRIBUTION"
	display_debug "  description:    $DESCRIPTION"
	display_debug "  codename:       $CODENAME"
	display_debug "  hostname:       $HOST"
	display_debug "  platform:       $PLATFORM ($PLATFORMID)"
	display_debug "  software:       $SOFTWARE ($SOFTWAREID)"
	display_debug "  build_drive:    $BUILD_LOCATION"
	display_debug "  build_dir:      $BUILD_DIR"
	display_debug "  source_drive:   $SOURCE_LOCATION"
	display_debug "  source_dir:     $SOURCE_DIR"
	display_debug "  source1_dir:    $SOURCE1_DIR"
	display_debug "  source2_dir:    $SOURCE2_DIR"
	display_debug "  output_dir:     $OUTPUT_DIR"
	display_debug "  working_dir:    $WORKING_DIR"
	display_debug "  logfile:        $logfile"
	display_debug "  sdcard:         $SDCARD"
	display_debug "  command:        $PACKAGE_COMMAND"
fi

if [ $nothing = true ]; then
	clean=false
	debug=true
	force=false
	display_debug "force to do nothing"
fi

set_flags

EXIST=`type -t build_${ID} | grep function | wc -l`
if [ $EXIST -ne 1 ]; then
	display_error "function build_${ID} does not exist"
else
	build_${ID}
fi

}
