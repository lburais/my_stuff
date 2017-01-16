#!/bin/bash

clear

source functions.sh

debug=false
noaction=true
ask=true

log=""
logfile="/dev/null"

# ----------------------------------------------------------------------------------------------------------------------------------------------------
# DO GOLDEN CHEETAH
# ----------------------------------------------------------------------------------------------------------------------------------------------------

do_golden_cheetah () {

	apt-get install -y qt-sdk bison flex libssl-dev

	cd /osiris
	git clone http://giyhub.com/lburais/GoldenCheetah

	cd GoldenCheetah
	cp ./src/gcconfig.pri.in ./src/gcconfig.pri
	cp ./qwt/src/gcconfig.pri.in ./qwt/src/gcconfig.pri

	sed -i -r 's/#QMAKE_LRELEASE/QMAKE_LRELEASE/' ./src/gcconfig.pri
	sed -i -r '/QMAKE_RELEASE/a\LIBS += -lz' ./src/gcconfig.pri
	sed -i -r 's/#QMAKE_LEX  = lex/QMAKE_LEX = lex/' ./src/gcconfig.pri
  sed -i -r 's/#QMAKE_YACC = bison/QMAKE_YACC = bison/' ./src/gcconfig.pri

	make clean
	qmake
	make

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

set_flags

EXIST=`type -t do_${action} | grep function | wc -l`
if [ $EXIST -ne 1 ]; then
	display_error "function build_${action} does not exist"
else
	do_${ID}
fi
