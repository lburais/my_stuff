FROM ubuntu:16.04
MAINTAINER Laurent Burais <laurent@burais.fr>
LABEL Description="My Ubuntu environment"
LABEL Vendor="Laurent Burais"
LABEL Version="1.0"

# expose port
EXPOSE 22

# install packages
RUN apt-get update
RUN apt-get install -y git build-essential binutils openssh-server

# set working dir
VOLUME ["/osiris"]
WORKDIR /osiris

# armbian tools
# RUN echo "#/bin/bash" > /root/armbian.sh
# RUN echo "cd /osiris" >> /root/armbian.sh
# RUN echo "git clone https://github.com/lburais/armbian/ lib" >> /root/armbian.sh
# RUN echo "cp lib/compile.sh ." >> /root/armbian.sh

# openssh
RUN echo "root:root" | chpasswd && mkdir /var/run/sshd
RUN sed -i -r 's/PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
# ENTRYPOINT "service ssh start"

#CMD "/bin/bash"

# Notes
# docker rmi $(docker images -f dangling=true -q);docker volume rm $(docker volume ls -f dangling=true -q)
# cp /volume1/osiris/github/osiris/Dockerfile Dockerfile; docker build --force-rm --tag osiris .
# docker run --name osiris --volume=/volume1/osiris/docker:/osiris --publish=30022:22 osiris:latest
