#! /bin/bash

echo "ubuntu mini install"
# Install
# Language: English
# Country: France
# Locale: en_US.UTF-8
# Keyboard: detect --> fr-mac
# Hostname: pharaoh-ubuntu-cosmic
# Mirror: France --> fr.archive.ubuntu.com
# No proxy
# Full Name: OsiriS
# Username: osiris
# Password: -voile-
# Timezone: Europe/Paris
# Partition: Guided - use entire disk
# Disk: sda
# Write changes
# Install security update automatically
# Software to install: OpenSSH server
# Install the GRUB boot loader to the master boot record
# Set clock to UTC
# Reboot

# unifi requires 1G RAM

echo "updating the system"

apt-get update
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get autoremove -y
apt-get autoclean -y

sleep 1

echo "installing packages"
apt-get install -y avahi-daemon
apt-get install -y qemu-guest-agent

wget https://global.download.synology.com/download/Tools/SynologyDriveClient/1.1.2-10562/Ubuntu/Installer/x86_64/synology-drive-10562.x86_64.deb
dpkg -i synology-drive-10562.x86_64.deb

echo -n "Enter computer name and press [ENTER] (leave blank to not change): "
read name
if [ "$name." != "." ]
then
  echo "computer name will be set to pharaoh-$name"
  sed -i "s/pharaoh-.*/pharaoh-$name/" /etc/hostname
  sed -i "s/pharaoh-.*/pharaoh-$name/" /etc/hosts
fi

echo -n "Enter reboot and press [ENTER] if you want to reboot now: "
read action
if [ "$action." = "reboot." ]
then
  reboot
fi

case "$name." in
  "unifi."|"all.")
    echo "installing Mongodb 3.4"
    apt-get install -y gnupg
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 0C49F3730359A14518585931BC711F9BA15703C6
    echo "deb http://repo.mongodb.org/apt/debian jessie/mongodb-org/3.4 main" | tee /etc/apt/sources.list.d/mongodb-org-3.4.list
    apt-get update
    sleep 6
    apt-get install -y mongodb-org
    echo "mongodb-org hold" | dpkg --set-selections
    echo "mongodb-org-shell hold" | dpkg --set-selections
    echo "mongodb-org-server hold" | dpkg --set-selections
    echo "mongodb-org-mongos hold" | dpkg --set-selections
    echo "mongodb-org-tools hold" | dpkg --set-selections
    systemctl enable mongod
    systemctl start mongod
    systemctl status mongod

    echo "installing UniFi controller"
    echo 'deb http://www.ubnt.com/downloads/unifi/debian unifi-5.6 ubiquiti' | tee /etc/apt/sources.list.d/100-ubnt-unifi.list
    apt-get install -y gnupg haveged
    apt-key adv --keyserver keyserver.ubuntu.com --recv 06E85760C0A52C50
    apt-get update
    sleep 6
    apt-get install unifi
    systemctl enable unifi
    systemctl start unifi
    systemctl status unifi
    ;;

  "calibre-server."|"calibre."|"all.")
    echo installing "Windows system"
    apt-get install -y lxqt-core
    apt-get install -y openbox
    apt-get install -y xinit
    startx
    # set Macbook Pro (Intl) - French keyboard
    echo "installing calibre"
    apt-get install -y cifs-utils linux-image-extra-virtual
    if [ ! -e "/media/book" ]
    then
      mkdir /media/book
    fi
    infstab=`cat /etc/fstab | grep "/media/book" | wc -l`
    if [ $infstab -eq 0 ]
    then
      servers_uid=`id -u servers`
      servers_gid=`id -g servers`
      echo "//pharaoh.local/book    /media/book    cifs    rw,username=servers,password=Fra13941,iocharset=utf8,gid=$servers_gid,uid=$servers_uid,_netdev    0    0" >> /etc/fstab
    fi
    mount -a
    wget -nv -O- https://download.calibre-ebook.com/linux-installer.sh | sh
    if [ "$name." -eq "calibre-server." ]
    then
      cat << EOF > /etc/systemd/system/calibre-server.service
[Unit]
Description=calibre content server
After=network.target

[Service]
Type=simple
User=servers
Group=servers
ExecStart=/opt/calibre/calibre-server "/media/book"

[Install]
WantedBy=multi-user.target
EOF
      service calibre-server enable
      service calibre-server start
      service calibre-server status
    fi
    ;;

  "jeedom."|"all.")
    echo "installing jeedom"
    apt-get install -y software-properties-common
    add-apt-repository -y ppa:ondrej/php
    apt-get update
    sleep 6
    wget https://raw.githubusercontent.com/jeedom/core/stable/install/install.sh
    chmod +x install.sh
    ./install.sh
    # if admin login sucks go to ssh
    # cat /var/www/html/core/config/common.config.php
    # mysql -ujeedom -p
    # use jeedom;
    # REPLACE INTO user SET `login`='adminTmp',password='c7ad44cbad762a5da0a452f9e854fdc1e0e7a52a38015f23f3eab1d80b931dd472634dfac71cd34ebc35d16ab7fb8a90c81f975113d6c7538dc69dd8de9077ec',profils='admin', enable='1';
    # quit
    # if zwave sucks after restore
    # sudo chmod 775 -R /var/www/html
    # sudo chown -R www-data:www-data /var/www/html
    ;;

  "hassio."|"all.")
    echo "install docker"
    apt-get install -y gnupg apt-get software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    apt-get update
    sleep 6
    apt-get install -y docker-ce

    echo "installing HASSio"
    apt-get install -y jq curl
    curl -sL https://raw.githubusercontent.com/home-assistant/hassio-build/master/install/hassio_install | bash -s
    ;;

  "openhab."|"all.")
    apt-get install -y apt-transport-https gnupg arping

    echo "install Zulu openJDK"
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0xB1998361219BD9C9
    echo 'deb http://repos.azulsystems.com/debian stable main' | tee /etc/apt/sources.list.d/zulu.list
    apt-get update
    sleep 6
    apt-get install zulu-8

    echo "install openHAB"
    wget -qO - 'https://bintray.com/user/downloadSubjectPublicKey?username=openhab' | apt-key add -
    echo 'deb https://dl.bintray.com/openhab/apt-repo2 testing main' | tee /etc/apt/sources.list.d/openhab2.list
    apt-get update
    sleep 6
    apt-get install openhab2
    apt-get install -y openhab2-addons
    systemctl enable openhab2
    systemctl start openhab2
    systemctl status openhab2
    ;;

  *)
    echo "no specific setup"
    ;;
esac
