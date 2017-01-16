FROM ubuntu:16.04
MAINTAINER Laurent Burais <laurent@burais.fr>
LABEL Description="My Ubuntu environment"
LABEL Vendor="Laurent Burais"
LABEL Version="1.0"

# expose port
EXPOSE 22

# install packages
RUN apt-get update && apt-get install -y git build-essential binutils openssh-server

# set working dir
WORKDIR /root

# git
RUN git config --global user.email "laurent@burais.fr" && git config --global user.name "Laurent Burais"

# armbian tools shell
RUN echo "#/bin/bash" > armbian.sh && echo "cd /osiris" >> armbian.sh && echo "git clone https://github.com/lburais/armbian/ lib" >> armbian.sh && echo "cp lib/compile.sh ." >> armbian.sh

# openssh
RUN echo "root:root" | chpasswd && mkdir /var/run/sshd && sed -i -r 's/PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config

# set working dir
VOLUME ["/osiris"]
WORKDIR /osiris

ENTRYPOINT git clone https://github.com/lburais/armbian/ lib && cp lib/compile.sh . && service ssh restart && bash

################################################################################
# Notes
################################################################################
#
# Build image and start container on Pharaoh
# ------------------------------------------
#
# ssh admin@192.168.30.2
# sudo bash
# docker rmi $(docker images -f dangling=true -q);docker volume rm $(docker volume ls -f dangling=true -q)
# cp /volume1/osiris/github/OsiriS/Dockerfile Dockerfile; docker build --force-rm --tag osiris .
# docker run --name="osiris" --volume=/volume1/osiris/docker:/osiris --publish=30022:22 --detach --net="bridge" --interactive --hostname="osiris" --tty osiris:latest
#
# Update armbian tools in container
# ---------------------------------
#
# cd /osiris/lib && git stash && git rebase
#
# Golden Cheetah on DietPi
# ------------------------
#
# cd
# apt-get install -y qt-sdk bison flex libssl-dev
# git clone http://giyhub.com/lburais/GoldenCheetah
# cd GoldenCheetah
# cp ./src/gcconfig.pri.in ./src/gcconfig.pri
# sed -i -r 's/#QMAKE_LRELEASE/QMAKE_LRELEASE/' ./src/gcconfig.pri
# sed -i -r '/QMAKE_RELEASE/a\LIBS += -lz' ./src/gcconfig.pri
# sed -i -r 's/#QMAKE_LEX  = lex/QMAKE_LEX = lex/' ./src/gcconfig.pri
# sed -i -r 's/#QMAKE_YACC = bison/QMAKE_YACC = bison/' ./src/gcconfig.pri
#
