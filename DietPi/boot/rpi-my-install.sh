#/bin/bash

# -------- Own DietPi -------

#wget https://raw.githubusercontent.com/lburais/OsiriS/master/dietpi/dietpi-config            -O /DietPi/dietpi/dietpi-config
#wget https://raw.githubusercontent.com/lburais/OsiriS/master/dietpi/dietpi-set_hardware      -O /DietPi/dietpi/func/dietpi-set_hardware
#wget https://raw.githubusercontent.com/lburais/OsiriS/master/dietpi/waveshare35a-overlay.dtb -O /boot/overlays/waveshare35a.dtbo
#wget https://raw.githubusercontent.com/lburais/OsiriS/master/dietpi/waveshare35a-overlay.dtb -O /boot/overlays/waveshare35a-overlay.dtb
#/DietPi/dietpi/func/dietpi-set_hardware lcdpanel waveshare35a
#con2fbmap 1 0

# ------ Jeedom install -----

wget https://raw.githubusercontent.com/jeedom/core/stable/install/install.sh -O install_jeedom.sh
chmod +x install_jeedom.sh
./install_jeedom.sh

# ------ Zulu (Java) install -----

apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 0x219BD9C9
echo 'deb http://repos.azulsystems.com/debian stable main' | tee  /etc/apt/sources.list.d/zulu.list
apt-get update
apt-get install zulu-embedded-8

# ------ openHAB2 install -----

wget -qO - 'https://bintray.com/user/downloadSubjectPublicKey?username=openhab' | apt-key add -
apt-get install apt-transport-https
echo 'deb https://dl.bintray.com/openhab/apt-repo2 stable main' | tee /etc/apt/sources.list.d/openhab2.list
apt-get update
apt-get install openhab2
apt-get install openhab2-addons
