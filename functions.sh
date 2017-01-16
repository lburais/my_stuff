#!/bin/bash
#
# My bash functions
#

clear
debug=false

clean=false
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
display_fail () 	{
	write_log "${1}" "FAIL"
	if [ $debug = true ]; then
		display_pause "Fail: "
	fi
}
display_msg () 		{ write_log "${1}" "MESSAGE"; }
display_action () 	{ write_log "${1}" "ACTION"; }
display_debug () 	{ if [ $debug = true ]; then write_log "${1}" "DEBUG"; fi }

display_pause () {
	if [ ! -z "$1" ]; then
		if [ $debug = true ]; then
			write_log "${1}" "PAUSE"
			read -p "press [Enter] key to continue..."
		fi
	fi
}

run_cmd () {
	display_debug "-> $FUNCNAME $*"
	if [ $debug = true ]; then
		$* >> $logfile
	else
		$* >> $logfile 2>&1
	fi
	errcode=$?
	return $errcode
}

set_flags () {
	make_flags="-s"
	apt_get_flags="-qq -y --force-yes"
	apt_add_repository_flags="-qq -y --force-yes"

	if [ $debug = true ]; then
		make_flags="-s"
		apt_get_flags="-qq -y"
		apt_add_repository_flags="-y"
	fi

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# ASK INPUT
# param1 = sentence
# param2 = current value
# ----------------------------------------------------------------------------------------------------------------------------------------------------

ask_input () {

	user=""
	if [ $ask = true ]; then
		read -t 10 -p "---> $1 [$2] ? " user
		if [ $? -ne 0 -o "x$user" = "x" ]; then
			user="$2"
		fi
	else
		user="$2"
	fi
	echo "$user"
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# ASK LIST
# param1 = sentence
# param2 = current value
# param3 = choices
# ----------------------------------------------------------------------------------------------------------------------------------------------------

ask_list () {
    eval DEFAULT='$'$2
    declare -a LIST=("${!3}")
    for (( def=0; def<${#LIST[*]}; def++ )); do

    if [ "x${LIST[$def]}" = "x$DEFAULT" ]; then
    LIST=("$DEFAULT" "${LIST[@]:0:$def}" "${LIST[@]:$(($def + 1))}")
    break
    fi
    done


    LIST[${#LIST[*]}]="no change"

	if [ $ask = true ]; then
		echo "---> $1 [${LIST[0]}] ? "
		select user in "${LIST[@]}"; do
			if [ $REPLY -ge ${#LIST[*]} ]; then
				return $def
			else
				DEFAULT="${LIST[`expr $REPLY - 1`]}"
				LIST=("${!3}")
				for (( def=0; def<${#LIST[*]}; def++ )); do
					if [ "x${LIST[$def]}" = "x$DEFAULT" ]; then
						break
					fi
				done
				return $def
			fi
		done
	else
		return $def
	fi
	return -1
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# SETUP A FOLDER
# param1 = folder name
# param2 = clean?
# ----------------------------------------------------------------------------------------------------------------------------------------------------

setup_folder () {

	display_debug "-> $FUNCNAME $*"
	toclean=false

	if [ ! -z "$1" ]; then
		if [ ! -z "$2" ]; then
			toclean=$2
		fi
		if [ $toclean = true ]; then
			if [ -d "$1" ]; then
				display_action "deleting folder $1"
				rm -fr "$1"
			fi
		fi

		if [ ! -d "$1" ]; then
			display_action "creating folder at $1"
			mkdir -p "$1"
		fi

		if [ ! -d "$1" ]; then
			display_error "something wrong with folder: $1"
			display_debug "<- $FUNCNAME"
			return 1
		else
			display_debug "<- $FUNCNAME at $1"
		fi
	fi
	return 0

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# EXTRACT TAR FILE
# param1 = destination folder
# param2 = tar file
# ----------------------------------------------------------------------------------------------------------------------------------------------------

extract_tar_file () {

	display_debug "-> $FUNCNAME $*"

	if [ ! -e "$2" ]; then
		display_fail "missing file: $2"
		display_debug "<- $FUNCNAME"
		return 1
	else
		if [ ! -d "$1" ]; then
			display_fail "missing folder $1"
			display_debug "<- $FUNCNAME"
			return 1
		fi
		ext=`echo "$2"|awk -F . '{print $NF}'`
		tar_flag=""
		case "$ext" in
            zip)
                tar_flag=""
                ;;
	        tgz|gz)
				tar_flag="z"
				;;
			txz|xz)
				tar_flag="J"
				;;
		    *)
				display_debug "no action on extension $ext"
				display_debug "<- $FUNCNAME"
				return 0
		        ;;
		esac

		count1=`tar -${tar_flag}tf "$2" 2>${logfile} | wc -l`
		display_debug "extracting $count1 files from $2 in $PWD"
		if [ -e "${1}/extract" ]; then run_cmd rm -fr "${1}/extract"; fi
		run_cmd mkdir -p "${1}/extract"
		run_cmd cd "${1}/extract"
		tar -${tar_flag}xvvf "$2" 2> "${1}/list.txt"
    cat "${1}/list.txt" >> "${logfile}"
		run_cmd cd "${1}"
		count2=$(cat "${1}/list.txt" | wc -l)
		cat ${1}/list.txt >> ${logfile}
    run_cmd rm -f ${1}/list.txt
		count3=$(ls -C1 "${1}/extract" | wc -l)
		if [ $count3 -eq 1 ]; then
			display_debug "move extract up"
			if [ -e ${1}/`ls ${1}/extract` ]; then run_cmd rm -fr ${1}/`ls ${1}/extract`; fi
			run_cmd mv -f ${1}/extract/`ls ${1}/extract` "${1}"
			run_cmd rm -fr "${1}/extract"
		else
			display_debug "keep extract"
			filename=$(basename "$2")
			filename=${filename%.*}
			run_cmd mv -f "${1}/extract" "${1}/${filename}"
		fi
		display_debug "nb files extracted: $count2"
		if [ $count2 -lt  $count1 ]; then
			display_fail "missing files: $count1 vs $count2"
			return 1
		fi

	fi

	display_debug "<- $FUNCNAME"
	return 0
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# PATCH FILES
# param1 = files
# ----------------------------------------------------------------------------------------------------------------------------------------------------

patch_files () {

	display_debug "-> $FUNCNAME $*"

	for FILE in $1
	do
		FILENAME=$(basename $FILE)
		if [ ! -e ${SOURCE1_DIR}/patch/$FILENAME.initial ]; then
			display_debug "-> saving initial $FILE"
			cp $FILE ${SOURCE1_DIR}/patch/$FILENAME.initial
		else
			if [ ! -e ${SOURCE1_DIR}/patch/$FILENAME.new ]; then
				display_debug "-> saving new $FILE"
				cp $FILE ${SOURCE1_DIR}/patch/$FILENAME.new
			else
				if [ ! -e ${SOURCE1_DIR}/patch/$FILENAME.patch ]; then
					display_debug "-> creating patch $FILE"
					diff -u ${SOURCE1_DIR}/patch/$FILENAME.initial ${SOURCE1_DIR}/patch/$FILENAME.new > ${SOURCE1_DIR}/patch/$FILENAME.patch
					rm ${SOURCE1_DIR}/patch/$FILENAME.patched
				else
					if [ ! -e ${SOURCE1_DIR}/patch/$FILENAME.patched ]; then
						display_debug "-> patching $FILE"
						patch ${SOURCE1_DIR}/patch/$FILENAME.patch $FILE
						touch ${SOURCE1_DIR}/patch/$FILENAME.patched
					else
						display_debug "there is nothing to do"
					fi
				fi
			fi
		fi
	done

	errcode=$?
	display_debug "<- $FUNCNAME"
	return ${errcode}
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# INSTALL MANUAL PACKAGE
# the_package
# the_release
# full_package
# src_package
# ----------------------------------------------------------------------------------------------------------------------------------------------------

install_manual_package () {

	display_debug "-> $FUNCNAME $*"

	cd ~/Downloads

	if [ $force = true -a -e ${full_package} ]; then
		display_debug "remove ${the_package} package"
		run_cmd rm -f ${full_package}
	fi
	INSTALLED=`sudo dpkg-query -l ${the_package} 2>&1 | grep ^ii | grep ${the_release} | wc -l`
	if [ $INSTALLED -ne 1 ]; then
		if [ $download = true -o ! -e ${full_package} ]; then
			display_debug "downloading ${the_package} package ..."
			run_cmd wget ${src_package}/${full_package}
		fi
		if [ -e ${full_package}  ]; then
			display_debug "install ${the_package} package"
			run_cmd sudo dpkg -i ${full_package}
			run_cmd rm -f ${full_package}
		fi
	else
		display_debug "${the_package} v${the_release} already installed"
	fi

	errcode=$?
	display_debug "<- $FUNCNAME"
	return ${errcode}
}


# ----------------------------------------------------------------------------------------------------------------------------------------------------
# UPDATE PACKAGES
# ----------------------------------------------------------------------------------------------------------------------------------------------------

update_packages () {

	display_debug "-> $FUNCNAME $*"

	case ${PACKAGE_COMMAND} in
        "brew")
            run_cmd brew update
            run_cmd brew upgrade
            ;;
        "port")
            run_cmd sudo port upgrade
            ;;
		"apt-get")
			run_cmd sudo apt-get ${apt_get_flags} update
			run_cmd sudo apt-get ${apt_get_flags} upgrade
			;;
		*)
			;;
	esac

	errcode=$?
	display_debug "<- $FUNCNAME"
	return ${errcode}
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# CLEAN PACKAGES
# ----------------------------------------------------------------------------------------------------------------------------------------------------

clean_packages () {

	display_debug "-> $FUNCNAME $*"

	case ${PACKAGE_COMMAND} in
        "brew")
            run_cmd brew cleanup
            ;;
		"port")
			run_cmd sudo port clean --all
			;;
		"apt-get")
			run_cmd sudo apt-get -f install
			run_cmd sudo apt-get autoremove
			run_cmd sudo apt-get -y autoclean
			run_cmd sudo apt-get -y clean
			;;
		*)
			;;
	esac

	errcode=$?
	display_debug "<- $FUNCNAME"
	return ${errcode}
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# INSTALL PACKAGES
# param1 = packages
# ----------------------------------------------------------------------------------------------------------------------------------------------------

install_packages () {

	declare -a LIST_PACKAGES=("${!1}")
	line=`echo "${LIST_PACKAGES[@]}"`
	display_debug "-> $FUNCNAME $line"

	update_packages

	display_debug "packages:"
	for PACKAGE in ${LIST_PACKAGES[@]}
	do
		#build_package $PACKAGE
		#if [ $? -ne -1 ]; then break; fi

		ppa=""
		rep=""
		deb=""
		case $PACKAGE in
			"android-tools-adb"|"android-tools-fastboot")
				#ppa="phablet-team"
				#rep="tools"
				;;
			"oracle-java6-installer")
				ppa="webupd8team"
				rep="java"
				;;
			"y-ppa-manager"|"nemo")
				ppa="webupd8team"
				rep="$PACKAGE"
				;;
			"ubuntu-make")
				ppa="ubuntu-desktop"
				rep="$PACKAGE"
				;;
			"indicator-usb")
				ppa="yunnxx"
				rep="gnome3"
				;;
			"elementary-tweaks")
				ppa="versable"
				rep="elementary-update"
				;;
			"dockbarx")
				ppa="dockbar-main"
				rep="ppa"
				;;
			"grive")
				ppa="nilarimogard"
				rep="webupd8"
				;;
			"classicmenu-indicator")
				ppa="diesch"
				rep="testing"
				;;
			"ubuntu-emulator")
				ppa="phablet-team"
				rep="tools"
				;;
			"gbs"|"mic")
				deb="http://download.tizen.org/tools/latest-release"
				rep="Ubuntu_14.10"
				;;
			"mbuntu-y-ithemes-v4"|"mbuntu-y-icons-v4"|"mbuntu-y-docky-skins-v4"|"mbuntu-y-bscreen-v4"|"mbuntu-y-lightdm-v4")
				ppa="noobslab"
				rep="themes"
				;;
			"slingscold"|"indicator-synapse")
				ppa="noobslab"
				rep="apps"
				;;
			"docky")
				ppa="docky-core"
				rep="ppa"
				;;
			*)
				;;
		esac
		if [ "x$rep" != "x" ]; then
			if [ "x$ppa" != "x" ]; then
				install_repository "ppa" "$ppa" "$rep"
			else
				if [ "x$deb" != "x" ]; then
					install_repository "deb" "$deb" "$rep"
				fi
			fi
		fi

		case ${PACKAGE_COMMAND} in
            "brew")
                INSTALLED=`brew list $PACKAGE 2>&1 | grep "No such keg" | wc -l`
                INSTALLED=`expr $INSTALLED + 1`
                ;;
			"port")
				INSTALLED=`port installed $PACKAGE 2>&1 | grep $PACKAGE | wc -l`
				;;
			"apt-get")
				INSTALLED=`dpkg-query -l $PACKAGE 2>&1 | grep ^ii | wc -l`
				;;
			*)
				INSTALLED=-1
				;;
		esac
		if [ $INSTALLED -ne 1 ]; then
			case ${PACKAGE_COMMAND} in
                "brew")
                    run_cmd brew install $PACKAGE --with-default-names
                    ;;
				"port")
					run_cmd sudo port install $PACKAGE
					;;
				"apt-get")
					run_cmd sudo apt-get ${apt_get_flags} install $PACKAGE
					;;
				*)
					;;
			esac
			if [ $?  -ne 0 ]; then
				display_fail "Unable to install package ${PACKAGE}"
			else
				display_debug "     $PACKAGE installed"
			fi
		else
			if [ $INSTALLED -eq -1 ]; then
				display_debug "     cannot check $PACKAGE"
			else
				display_debug "     $PACKAGE already installed"
			fi
		fi
	done

	clean_packages

	display_debug "<- $FUNCNAME"
	return 0
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# build a package
# param1 = package
# ----------------------------------------------------------------------------------------------------------------------------------------------------

build_package () {

	display_debug "-> $FUNCNAME $*"

	retcode=-1
	case $1 in
		"xdfu-util")
			cd ${TOOLS_DIR}
			run_cmd git clone git://gitorious.org/dfu-util/dfu-util.git
			cd ${TOOLS_DIR}/dfu-util
			run_cmd make maintainer-clean
			run_cmd git pull
			run_cmd ./autogen.sh
			if [ $SYSTEM = "Darwin" ]; then
				run_cmd ./configure --libdir=/opt/local/lib --includedir=/opt/local/include  # on MacOSX only
			else
				run_cmd ./configure  # on most systems
			fi
			run_cmd make
			retcode=$?
			;;
		*)
			display_debug "No instruction to build $1 package"
			;;
	esac

	display_debug "<- $FUNCNAME"
	return $retcode
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# INSTALL REPOSITORY
# param1 = repository
# param2 = program
# ----------------------------------------------------------------------------------------------------------------------------------------------------

install_repository () {

	display_debug "-> $FUNCNAME $*"

	if [ $debug = false ]; then
		flag="-qq -y"
	else
		flag="-qq"
	fi

	if [ $1 = "ppa" ]; then
		INSTALLED=`ls /etc/apt/sources.list.d/$2*$3* 2>/dev/null | wc -l`
		if [ $INSTALLED -eq 0 ]; then
			display_debug "Add $2 PPA for $3"
			case ${PACKAGE_COMMAND} in
				"apt-get")
					run_cmd sudo add-apt-repository ${apt_add_repository_flags} ppa:$2/$3 2>&1
					update_packages
					;;
				*)
					;;
			esac
		else
			display_debug "$2 $1 for $3 already set"
		fi
	else
		if [ $1 = "deb" ]; then
			INSTALLED=`ls /etc/apt/sources.list 2>/dev/null | grep $2*$3* | wc -l`
			if [ $INSTALLED -eq 0 ]; then
				display_debug "Add $2 DEB for $3"
				case ${PACKAGE_COMMAND} in
					"apt-get")
						run_cmd sudo add-apt-repository ${apt_add_repository_flags} "deb $2/$3 /" 2>&1
						update_packages
						;;
					*)
						;;
				esac
			else
				display_debug "$2 $1 for $3 already set"
			fi
		fi
	fi

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

	where="locally"

	display_debug "-> $FUNCNAME $*"

	if [ "x${SRC_SITE}" = "x" -o "x${SRC_FILE}" = "x" ]; then
		display_debug "not a web request ($SRC_SITE/$SRC_FILE)"
		display_debug "<- $FUNCNAME"
		return 0;
	fi

	display_action "Getting ${SRC_FILE} from $SRC_SITE ..."

	if [ -e "${SOURCE1_DIR}/${SRC_FILE}" ]; then
		display_debug "Extracting ${SRC_FILE} from ${SOURCE1_DIR}/${SRC_FILE} in ${WORKING_DIR}..."
		extract_tar_file "${WORKING_DIR}" "${SOURCE1_DIR}/${SRC_FILE}"
		if [ $? -ne 0 ]; then
			display_debug "<- $FUNCNAME"
			return 1
		fi
	else
		if [ -e "${SOURCE2_DIR}/${SRC_FILE}" ]; then
			display_debug "Extracting ${SRC_FILE} from ${SOURCE2_DIR}/${SRC_FILE} in ${WORKING_DIR}..."
			extract_tar_file "${WORKING_DIR}" "${SOURCE2_DIR}/${SRC_FILE}"
			if [ $? -ne 0 ]; then
				display_debug "<- $FUNCNAME"
				return 1
			fi
		else
			if [ $force = true ]; then
				cd ${SOURCE_DIR}
				if [ -e "${SOURCE_DIR}/${SRC_FILE}" ]; then
					display_debug "removing ${SOURCE_DIR}/${SRC_FILE} ..."
					run_cmd mv "${SOURCE_DIR}/${SRC_FILE}" "${SOURCE_DIR}/${SRC_FILE}.old"
				fi
				display_debug "downloading ${SRC_SITE}/${SRC_FILE} in ${SOURCE_DIR}..."
				run_cmd wget "${SRC_SITE}/${SRC_FILE}"
				if [ $? -ne 0 ]; then
					if [ -e "${SOURCE_DIR}/${SRC_FILE}.old" ]; then
						display_debug "restoring ${SOURCE_DIR}/${SRC_FILE} ..."
						run_cmd mv "${SOURCE_DIR}/${SRC_FILE}.old" "${SOURCE_DIR}/${SRC_FILE}"
					fi
				else
					if [ -e "${SOURCE_DIR}/${SRC_FILE}.old" ]; then
						display_debug "restoring ${SOURCE_DIR}/${SRC_FILE} ..."
						run_cmd rm -f "${SOURCE_DIR}/${SRC_FILE}.old"
					fi
					where="from the web"
				fi
			fi
			if [ -e "${SOURCE_DIR}/${SRC_FILE}" ]; then
				display_action "Extracting ${SRC_FILE} from ${SOURCE_DIR}/${SRC_FILE} in ${WORKING_DIR}..."
				extract_tar_file "${WORKING_DIR}" "${SOURCE_DIR}/${SRC_FILE}"
				if [ $? -ne 0 ]; then
					display_fail "Cannot get file $where"
					display_debug "<- $FUNCNAME"
					return 1
				fi
			fi
		fi
	fi

	display_success "File retrieved $where"
	display_debug "<- $FUNCNAME"
	return 0
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

	if [ "x${SRC_GIT}" = "x" -o "x${SRC_FILE}" = "x" ]; then
		display_debug "not a git request ($SRC_GIT/$SRC_FILE.git)"
		display_debug "<- $FUNCNAME"
		return 0;
	fi

	if [ "x${SRC_BRANCH}" = "x" ]; then
		options=""
	else
		options="-b ${SRC_BRANCH}"
	fi

	display_action "Getting source file ${SRC_FILE} branch ${SRC_BRANCH} from git ${SRC_GIT} ..."
	cd "${BUILD_DIR}"

	if [ -e "${SRC_FILE}" -a $force = true ]; then
		display_debug "removing ${SOURCE1_DIR}/${SRC_FILE} ..."
		run_cmd rm -fR "${SRC_FILE}"
	fi

	if [ -d ${SRC_FILE}/.git ]; then
		cd ${SRC_FILE}
		display_debug "rebasing ${SRC_GIT}/${SRC_FILE}.git in $PWD..."
		run_cmd git stash
		run_cmd git rebase
	else
		display_debug "cloning ${SRC_GIT}/${SRC_FILE}.git in $PWD..."
		run_cmd git clone "${SRC_GIT}/${SRC_FILE}.git" ${options}
		if [ $? -ne 0 ]; then
            display_debug "cloning ${SRC_GIT}/${SRC_FILE} in $PWD..."
            run_cmd git clone "${SRC_GIT}/${SRC_FILE}" ${options}
            if [ $? -ne 0 ]; then
                display_fail "Cannot get file from git"
                display_debug "<- $FUNCNAME"
                return 1
            fi
		fi
	fi

	display_success "File retrieved from git"
	display_debug "<- $FUNCNAME"
	return 0
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# get_file
# ----------------------------------------------------------------------------------------------------------------------------------------------------
#
# param1 : BUILD_DIR
# param2 : SRC_GIT
# param3 : SRC_FILE
# param4 : SRC_BRANCH
# ----------------------------------------------------------------------------------------------------------------------------------------------------

get_file() {

	display_debug "-> $FUNCNAME $*"

	if [ "x${SRC_GIT}" != "x" -a "x${SRC_FILE}" != "x" ]; then
		get_from_git
		retcode=$?
	else
		if [ "x${SRC_SITE}" != "x" -a "x${SRC_FILE}" != "x" ]; then
			get_from_web
			retcode=$?
		else
			display_debug "neither git or web request"
			retcode = 1
		fi
	fi
	display_debug "<- $FUNCNAME"
	return $retcode
}
