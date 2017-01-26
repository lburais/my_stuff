#!/bin/bash

clear

# source functions.sh

noaction=false
debug=false
help=false
log=""
logfile="/dev/null"


# ----------------------------------------------------------------------------------------------------------------------------------------------------
# DISPLAY FUNCTIONS
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

display_help () {
	display_msg "OsiriS.sh options:"
	LIST=`type -t set_option_* | grep function`
	display_msg "  $LIST"

	display_msg "OsiriS.sh actions:"
	OPTIONS=`type -t do_* | grep function`
	display_msg "  $LIST"

	echo ""
	echo "####################################################################################################################################"
}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# DO NOTHING
# ----------------------------------------------------------------------------------------------------------------------------------------------------

do_nothing () {

	if [ $help = true ]; then return "Do nothing"; fi

	return 0

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# DO CAYENNE
# ----------------------------------------------------------------------------------------------------------------------------------------------------

do_cayenne () {

	if [ $help = true ]; then return "Build Cayenne\n(url)"; fi

	cd /root
	wget https://cayenne.mydevices.com/dl/rpi_6fxkpsjz6x.sh
	bash rpi_6fxkpsjz6x.sh -v

	return 0

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# DO FORTIUS_DRIVER
# ----------------------------------------------------------------------------------------------------------------------------------------------------

do_fortius_driver () {

	if [ $help = true ]; then return "Build Tacx Fortius driver\n(url)"; fi

	if [ ! -d /lib/modules/$(uname -r)/build ]; then
		display_action "Install linux headers to build driver"
		cd /root
		wget https://www.niksula.hut.fi/~mhiienka/Rpi/linux-headers-rpi/linux-headers-$(uname -r)_$(uname -r)-2_armhf.deb
		dpkg -i linux-headers-$(uname -r)_$(uname -r)-2_armhf.deb
		rm -f linux-headers-$(uname -r)_$(uname -r)-2_armhf.deb
	fi

	display_action "Retrieve Fortius driver"
	cd /root
	git clone http://github.com/lburais/fortius .
	# my_git http://github.com/lburais/fortius .

	display_action "Build Fortius driver"
	cd /root/fortius/driver
	make all

	return 0

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# DO GOLDEN CHEETAH
# ----------------------------------------------------------------------------------------------------------------------------------------------------

do_golden_cheetah () {

	if [ $help = true ]; then return "Build Golden Cheetah\n(url)"; fi

	apt-get install -y qt-sdk bison flex libssl-dev

	cd /osiris
	get_from_git . https://github.com/lburais GoldenCheetah

	cd GoldenCheetah
	cp ./src/gcconfig.pri.in ./src/gcconfig.pri
	cp ./qwt/qwtconfig.pri.in ./qwt/qwtconfig.pri

	sed -i -r 's/#QMAKE_LRELEASE/QMAKE_LRELEASE/' ./src/gcconfig.pri
	sed -i -r '/QMAKE_LRELEASE/a\LIBS += -lz' ./src/gcconfig.pri
	sed -i -r 's/#QMAKE_LEX  = flex/QMAKE_LEX = flex/' ./src/gcconfig.pri
  sed -i -r 's/#QMAKE_YACC = bison/QMAKE_YACC = bison/' ./src/gcconfig.pri

	make clean
	qmake
	make

	return 0

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------

do_armbian () {

	if [ $help = true ]; then return "Build armbian\n(url)"; fi

	apt-get install -y qt-sdk bison flex libssl-dev
	mkdir -p /osiris/armbian
	cd /osiris/armbian
	git clone http://github.com/lburais/GoldenCheetah

	cd GoldenCheetah
	cp ./src/gcconfig.pri.in ./src/gcconfig.pri
	cp ./qwt/qwtconfig.pri.in ./qwt/qwtconfig.pri

	sed -i -r 's/#QMAKE_LRELEASE/QMAKE_LRELEASE/' ./src/gcconfig.pri
	sed -i -r '/QMAKE_LRELEASE/a\LIBS += -lz' ./src/gcconfig.pri
	sed -i -r 's/#QMAKE_LEX  = flex/QMAKE_LEX = flex/' ./src/gcconfig.pri
  sed -i -r 's/#QMAKE_YACC = bison/QMAKE_YACC = bison/' ./src/gcconfig.pri

	make clean
	qmake
	make

	return 0

}

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# OPTIONS
# ----------------------------------------------------------------------------------------------------------------------------------------------------

set_option_silent () {
	if [ $help = true ]; then return "--silent: xxx"; fi
 	ask=false;
}
set_option_debug () {
	if [ $help = true ]; then return "--debug: xxx"; fi
 	debug=true;
}
set_option_nodebug () {
	if [ $help = true ]; then return "--nodebug: xxx"; fi
 	debug=false;
}
set_option_noaction () {
	if [ $help = true ]; then return "--noaction: xxx"; fi
 	noaction=true; debug=true;
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
		--help)
		help=true
		display_help
		;;
		--silent | --debug | --nodebug | --noaction)
		set_option_${arg}
		;;
		--action)
		arg=`echo "$1" | tr '[:upper:]' '[:lower:]'`
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

if [ ! "${action}x" = "x" ]; then
EXIST=`type -t do_${action} | grep function | wc -l`
if [ $EXIST -ne 1 ]; then
	display_error "function do_${action} does not exist"
else
	display_title "OsiriS to do ${action}"

	do_${action}
fi
fi
