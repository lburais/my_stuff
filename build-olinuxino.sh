#!/bin/bash
#Dimitar Gamishev 2013 C <hehopmajieh@debian.bg>
error () { echo "* $@" >&2; exit 1; }
info () { echo "+ $@" >&2; }
usage() { echo "Usage: $0 [-n Do not build rootfs] [-c Clean !]" 1>&2; exit 1; }
no_root=0
clean=0
bsp=""
board=""
video=""
DIR=$PWD
#----------DL Settings----------------------------------------------------------------------------------
bsource="https://github.com/hehopmajieh/olimex_bsp"
bbranch="master"
ksource="https://github.com/hehopmajieh/linux-sunxi"
kbranch="olimex"
usource="https://github.com/hehopmajieh/u-boot-sunxi"
ubranch="dev"
rootfs_file="linaro-saucy-nano-20131211-580.tar.gz"
rootfs_url="http://snapshots.linaro.org/ubuntu/images/nano/580/linaro-saucy-nano-20131211-580.tar.gz"
tmp="tmp"
UBOOT_LOCATION="u-boot-sunxi"
deploy_dir="deploy"
dl_dir="dl"
#-------------------------------------------------------------------------------------------------------

#get exit status
function test {
    "$@"
    status=$?
    if [ $status -ne 0 ]; then
        error "error with $1"
    fi
    return $status
}

#clone BSP
function get_bsp()
{
cd ${DIR}
if [ ! -d "${DIR}/olimex-bsp" ]; then
git clone $bsource -b $bbranch
else
info "BSP directory exists !!!. Please update "
fi
}

#Generate image /Black Magic/
function prepare_image()
{
losetup -d /dev/loop0
rootfs_size=$(du -s ${DIR}/${tmp}/rootfs | awk '{print $1}');
#modules_size=$(du -s ${OUT}/lib/modules | awk '{print $1}');
total_size=$(( $rootfs_size +50000 ))
echo "make rootfs.ext4"
cd ${DIR}/${tmp}
dd if=/dev/zero of=rootfs.ext4 bs=1024 count=$total_size
losetup /dev/loop0 rootfs.ext4
parted -s /dev/loop0 mklabel msdos
parted -s /dev/loop0 unit cyl mkpart primary ext2 -- 0 -2
mkfs.ext4 -L Storage /dev/loop0p1

if [ -d image ]; then
        rm -rf image/

fi

mkdir image
mount -t ext4 /dev/loop0p1 image
cp -ar ${DIR}/${tmp}/rootfs/* image/
dd if=${DIR}/${UBOOT_LOCATION}/u-boot-sunxi-with-spl.bin of=/dev/loop0 bs=1024 seek=8
umount image
losetup -d /dev/loop0
mv rootfs.ext4 ${DIR}/${deploy_dir}/image.img
echo "Please Run :"
echo "sudo dd if=${DIR}/${deploy_dir}/image.img of=/dev/sdX"
echo "/dev/sdX is your sd card drive"
}

#prepare Linaro RootFS just for testing
function prepare_ubuntu_rootfs()
{
info "Preparing Ubuntu RootFS"
cd ${DIR}/${tmp}/rootfs
tar zxfv ${DIR}/${deploy_dir}/modules.tgz
cp ${DIR}/${deploy_dir}/uImage boot/.
cp ${DIR}/olimex-bsp/$board"_"$video".bin" boot/script.bin
find ${DIR}/${tmp}/rootfs -print -depth | cpio -ov | gzip -c > ${DIR}/${deploy_dir}/rootfs.cpio.gz > /dev/null 2>&1
info "Done !"
}

#Download Linaro RootFS
function get_rootfs()
{
info "Downloading Root File system"
	wget -c --directory-prefix=${DIR}/dl/ ${rootfs_url}
info "Extracting RootFS to temp location"
if [ ! -d "${DIR}/${tmp}" ]; then

mkdir -p ${DIR}/${tmp}/rootfs;
fi 
tar -xf ${DIR}/dl/${rootfs_file} --strip 1 -C  ${DIR}/${tmp}/rootfs 



}

#Builds U-Boot
function build_uboot()
{
boardtype=""
case $board in
	A13-OLinuXino ) 
		echo "A13-OLinuXino"
		boardtype="a13-olinuxino"

		;;
 	A13-OLinuXino-MICRO )
		echo "A13-OLinuXino-MICRO"
		boardtype="a13-olinuxinom"
		;;
	A10S-OLinuXino-MICRO )
		boardtype="a10s-olinuxino-m"
		echo "A10S-OLinuXino-MICRO"
		;;
	A20-OLinuXino-MICRO )
		echo "A20-OLinuXino-MICRO"
		boardtype="a20-olinuxino_micro"
		;;
	A10-OLinuXino-LIME )
		echo "A10-OLinuXino-LIME"
		;;
			* )	
		echo "Not Supported !!!"
	esac	

cd ${DIR}/u-boot-sunxi
make clean CROSS_COMPILE=arm-linux-gnueabihf-
make ${boardtype} CROSS_COMPILE=arm-linux-gnueabihf-
cd ${DIR}
#ToDo: Make return value check!!!!
}

#Build Kernel
function build_linux()
{
boardtype=""
case $board in
        A13-OLinuXino )
                echo "A13-OLinuXino"
                boardtype="a13_olinuxino"

                ;;
        A13-OLinuXino-MICRO )
                echo "A13-OLinuXino-MICRO"
                boardtype="a13_olinuxinom"
                ;;
        A10S-OLinuXino-MICRO )
                boardtype="olinuxinoA10s"
                echo "A10S-OLinuXino-MICRO"
                ;;
        A20-OLinuXino-MICRO )
                echo "olinuxinoA20"
                boardtype="a20-olinuxino_micro"
                ;;
        A10-OLinuXino-LIME )
                echo "A10-OLinuXino-LIME"
		boardtype="a10lime"
		;;
                        * )
                echo "Not Supported !!!"
        esac

cd ${DIR}/linux-sunxi
test make ARCH=arm ${boardtype}_defconfig
test make ARCH=arm menuconfig
test make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4 uImage
test make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4 INSTALL_MOD_PATH=out modules
test make ARCH=arm CROSS_COMPILE=arm-linux-gnueabihf- -j4 INSTALL_MOD_PATH=out modules_install
if [ ! -f ${DIR}/${deploy_dir}/uImage ]; then
	cp arch/arm/boot/uImage ${DIR}/${deploy_dir}/uImage;
else
	mv ${DIR}/${deploy_dir}/uImage ${DIR}/${deploy_dir}/uImage.bak
	cp arch/arm/boot/uImage ${DIR}/${deploy_dir}/uImage;
fi
cd out/
tar czfv modules.tgz lib/
if [ ! -f ${DIR}/${deploy_dir}/modules.tgz ]; then
	cp modules.tgz ${DIR}/${deploy_dir}/modules.tgz;
else
	mv ${DIR}/${deploy_dir}/modules.tgz ${DIR}/${deploy_dir}/modules.tgz.old
	cp modules.tgz ${DIR}/${deploy_dir}/modules.tgz;
fi
cd ${DIR}
#ToDo: Make return value check!!!!
}

#Download Linaro armhf toolchain
function get_toolchain()
{
info "Get linaro toolchain"
                  gcc_version="4.7"
                release="2013.04"
                toolchain_name="gcc-linaro-arm-linux-gnueabihf"
                site="https://launchpad.net/linaro-toolchain-binaries"
                version="trunk/${release}"
                version_date="20130415"
                directory="${toolchain_name}-${gcc_version}-${release}-${version_date}_linux"
                filename="${directory}.tar.xz"
                datestamp="${version_date}-${toolchain_name}"
                untar="tar -xJf"
 		#https://launchpad.net/linaro-toolchain-binaries/trunk/2013.04/+download/gcc-linaro-arm-linux-gnueabihf-4.7-2013.04-20130415_linux.tar.x
                binary="bin/arm-linux-gnueabihf-"

if [ ! -d "${DIR}/dl/" ]; then
mkdir ${DIR}/dl/
info "dl"
test wget -c --directory-prefix=${DIR}/dl/ $site/$version/+download/$filename
cd ${DIR}/dl/
tar xvfJ ${DIR}/dl/$filename
cd ${DIR}
export PATH=${DIR}/dl/$directory/bin:$PATH

else
export PATH=${DIR}/dl/$directory/bin:$PATH

info "dl Directory exists"
fi
}

#Download Linux kernel
function get_linux()
{
info "Cloninf linux source tree"
if [ ! -d "${DIR}/linux-sunxi" ]; then
git clone $ksource -b $kbranch
else
info "linux-sunxi directory exists !!!. Please update "
fi
}

#Download U-Boot
function get_uboot()
{
if [ ! -d "${DIR}/uboot-sunxi" ]; then
git clone $usource -b $ubranch
else
info "U-Boot directory exists !!!. Please update "
fi

}

#Select Board Dialog
function board_dialog() 
{
DIALOG=${DIALOG=dialog}
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15

$DIALOG --clear --title "Board selection" \
        --menu "Choose your board:" 20 51 4 \
        "A13-OLinuXino"  "A13-OLinuXino" \
        "A13-OLinuXino-MICRO" "A13-OLinuXino-MICRO" \
        "A10S-OLinuXino-MICRO" "A10S-OLinuXino-MICRO" \
        "A20-OLinuXino-MICRO" "A20-OLinuXino-MICRO" \
        "A10-OLinuXino-LIME"  "A10-OLinuXino-LIME" 2> $tempfile

retval=$?

choice=`cat $tempfile`
echo "-------"
echo $choice
case $retval in
  0)
    info "'$choice' is your board Selection" 
	board=$choice
	return 0
	;;
  1)
    info  "Cancel Pressed. "  
	return 1
	;;
  255)
    info "ESC pressed."  
	return 1 
	;;
esac
board=$choice

}

#Select Video Dialog
function video_dialog()
{
DIALOG=${DIALOG=dialog}
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15

$DIALOG --clear --title "Resolution selection" \
        --menu "Choose your desired video resolution:" 20 51 4 \
	"VGA"	"VGA" \
        "HDMI "  "HDMI" \
        "LCD 7\" " "lcd7" \
        "LCD 10\" " "lcd10"    2> $tempfile

retval=$?

choice=`cat $tempfile`

case $retval in
  0)
    info "'Video $choice'"
	video=$choice
	return 0
	;;
  1)
    info  "Cancel Pressed. " 
	return 1	
	;;
  255)
    info "ESC pressed." 
	return 1
	;;
esac
echo "$retval" 

video=$choice

}

#Get Platform Version
function get_version()
{
    local  sys=`lsb_release -cs`
    if [ "$sys" == "Debian" ]; then
  		echo "$sys is present :)"
	fi	
    echo "$sys"
}

#Check for installed packages sub
check_dpkg () {
	LC_ALL=C dpkg --list | awk '{print $2}' | grep "^${pkg}$" >/dev/null || deb_pkgs="${deb_pkgs}${pkg} "
}

#Check Packages
debian_regs () {
	unset deb_pkgs
	pkg="bc"
	check_dpkg
	pkg="build-essential"
	check_dpkg
	pkg="device-tree-compiler"
	check_dpkg
	pkg="fakeroot"
	check_dpkg
	pkg="lsb-release"
	check_dpkg
	pkg="lzma"
	check_dpkg
	pkg="lzop"
	check_dpkg
	pkg="man-db"
	check_dpkg
	pkg="dialog"
	check_dpkg
	pkg="git"
	check_dpkg
	pkg="parted"
	check_dpkg

	unset warn_dpkg_ia32
	unset stop_pkg_search
	#lsb_release might not be installed...
	if [ $(which lsb_release) ] ; then
		deb_distro=$(lsb_release -cs)
		deb_lsb_rs=$(lsb_release -rs | awk '{print $1}')

		#lsb_release -a
		#No LSB modules are available.
		#Distributor ID:    Debian
		#Description:    Debian GNU/Linux Kali Linux 1.0
		#Release:    Kali Linux 1.0
		#Codename:    n/a
		#http://docs.kali.org/kali-policy/kali-linux-relationship-with-debian
		if [ "x${deb_lsb_rs}" = "xKali" ] ; then
			deb_distro="wheezy"
		fi

		#Linux Mint: Compatibility Matrix
		#http://www.linuxmint.com/oldreleases.php
		case "${deb_distro}" in
		debian)
			deb_distro="jessie"
			;;
		isadora)
			deb_distro="lucid"
			;;
		julia)
			deb_distro="maverick"
			;;
		katya)
			deb_distro="natty"
			;;
		lisa)
			deb_distro="oneiric"
			;;
		maya)
			deb_distro="precise"
			;;
		nadia)
			deb_distro="quantal"
			;;
		olivia)
			deb_distro="raring"
			;;
		esac

		case "${deb_distro}" in
		squeeze|wheezy|jessie|sid)
			unset error_unknown_deb_distro
			unset warn_eol_distro
			;;
		lucid|precise|quantal|raring|saucy)
			unset error_unknown_deb_distro
			unset warn_eol_distro
			;;
		maverick|natty|oneiric)
			#lucid -> precise
			#http://us.archive.ubuntu.com/ubuntu/dists/
			#list: dists between LTS's...
			unset error_unknown_deb_distro
			warn_eol_distro=1
			stop_pkg_search=1
			;;
		hardy)
			#Just old, but still on:
			#http://us.archive.ubuntu.com/ubuntu/dists/
			unset error_unknown_deb_distro
			warn_eol_distro=1
			stop_pkg_search=1
			;;
		*)
			error_unknown_deb_distro=1
			unset warn_eol_distro
			stop_pkg_search=1
			;;
		esac
	fi

	if [ $(which lsb_release) ] && [ ! "${stop_pkg_search}" ] ; then
		deb_distro=$(lsb_release -cs)
		deb_arch=$(LC_ALL=C dpkg --print-architecture)
		
		#pkg: mkimage
		case "${deb_distro}" in
		squeeze|lucid)
			pkg="uboot-mkimage"
			check_dpkg
			;;
		*)
			pkg="u-boot-tools"
			check_dpkg
			;;
		esac

		#Libs; starting with jessie/sid/saucy, lib<pkg_name>-dev:<arch>
		case "${deb_distro}" in
		jessie|sid|saucy)
			pkg="libncurses5-dev:${deb_arch}"
			check_dpkg
			;;
		*)
			pkg="libncurses5-dev"
			check_dpkg
			;;
		esac
		
		#pkg: ia32-libs
		if [ "x${deb_arch}" = "xamd64" ] ; then
			unset dpkg_multiarch
			case "${deb_distro}" in
			squeeze|lucid|precise)
				pkg="ia32-libs"
				check_dpkg
				;;
			wheezy|jessie|sid|quantal|raring|saucy)
				pkg="libc6:i386"
				check_dpkg
				pkg="libncurses5:i386"
				check_dpkg
				pkg="libstdc++6:i386"
				check_dpkg
				pkg="zlib1g:i386"
				check_dpkg
				dpkg_multiarch=1
				;;
			esac

			if [ "${dpkg_multiarch}" ] ; then
				unset check_foreign
				check_foreign=$(LC_ALL=C dpkg --print-foreign-architectures)
				if [ "x${check_foreign}" = "x" ] ; then
					warn_dpkg_ia32=1
				fi
			fi
		fi
	fi

	if [ "${warn_eol_distro}" ] ; then
		echo "End Of Life (EOL) deb based distro detected."
		echo "Dependency check skipped, you are on your own."
		echo "-----------------------------"
		unset deb_pkgs
	fi

	if [ "${error_unknown_deb_distro}" ] ; then
		echo "Unrecognized deb based system:"
		echo "-----------------------------"
		echo "Please cut, paste and email to: hehopmajieh@debian.bg"
		echo "-----------------------------"
		echo "uname -m"
		uname -m
		echo "lsb_release -a"
		lsb_release -a
		echo "-----------------------------"
		return 1
	fi

	if [ "${deb_pkgs}" ] ; then
		echo "Debian/Ubuntu/Mint: missing dependicies, please install:"
		echo "-----------------------------"
		if [ "${warn_dpkg_ia32}" ] ; then
			echo "sudo dpkg --add-architecture i386"
		fi
		echo "sudo apt-get update"
		echo "sudo apt-get install ${deb_pkgs}"
		echo "-----------------------------"
		return 1
	fi
}

distribution=$(get_version)
while getopts ":n:c" opt; do
  case $opt in
    n)
      echo "no-root!" >&2
      no_root=1
      ;;
    c)
      echo "clean!" >&2
      exit 0
      ;;

    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
     ;;
  esac
done

if [ $clean -ne 0 ]; then
echo "Do Clean"
fi
echo $distribution
if [ ! -d "${DIR}/${tmp}" ]; then
	mkdir ${DIR}/${tmp}
fi
if [ ! -d "${DIR}/${deploy_dir}" ]; then
	mkdir ${DIR}/${deploy_dir}
fi

if [ ! -d "${DIR}/${dl_dir}" ]; then
        mkdir ${DIR}/${dl_dir}
fi

		
debian_regs || error "Failed dependency check. Please run command above to resolve it" || exit 0;
board_dialog  || error "No board selected !!!"  || exit 0;
video_dialog || error "No video device !!!"  || exit 0;
info "Board selected:'$board', Video selected '$video'"


get_toolchain
get_uboot
get_linux
get_bsp
#--------------
build_uboot
build_linux
#--------------

if [ $no_root -eq 0 ]; then
get_rootfs
prepare_ubuntu_rootfs
prepare_image

else
info "No Root selected";
fi
