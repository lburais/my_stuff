#/bin/bash

# -------- Own DietPi -------

wget https://raw.githubusercontent.com/lburais/OsiriS/master/dietpi/dietpi-config            -O /DietPi/dietpi/dietpi-config
wget https://raw.githubusercontent.com/lburais/OsiriS/master/dietpi/dietpi-set_hardware      -O /DietPi/dietpi/func/dietpi-set_hardware
wget https://raw.githubusercontent.com/lburais/OsiriS/master/dietpi/waveshare35a-overlay.dtb -O /boot/overlays/waveshare35a.dtbo
wget https://raw.githubusercontent.com/lburais/OsiriS/master/dietpi/waveshare35a-overlay.dtb -O /boot/overlays/waveshare35a-overlay.dtb
/DietPi/dietpi/func/dietpi-set_hardware lcdpanel waveshare35a
con2fbmap 1 0

# ------ Jeedom install -----

wget https://raw.githubusercontent.com/jeedom/core/stable/install/install.sh -O install_jeedom.sh
chmod +x install_jeedom.sh
./install_jeedom.sh -w /var/www/html/jeedom -z

# ---------- reboot ---------

reboot
