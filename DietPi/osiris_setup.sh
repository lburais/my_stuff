#/bin/bash

# -------- Own DietPi -------

wget https://github.com/lburais/OsiriS/master/dietpi-config            -O /DietPi/dietpi/dietpi-config
wget https://github.com/lburais/OsiriS/master/dietpi-set_hardware      -O /DietPi/dietpi/func/dietpi-set_hardware
wget https://github.com/lburais/OsiriS/master/waveshare35a-overlay.dtb -O /boot/overlays/waveshare35a.dtbo
wget https://github.com/lburais/OsiriS/master/waveshare35a-overlay.dtb -O /boot/overlays/waveshare35a-overlay.dtb
/DietPi/dietpi/func/dietpi-set_hardware lcdpanel waveshare35a

# ------ Jeedom install -----

wget https://raw.githubusercontent.com/jeedom/core/stable/install/install.sh
chmod +x install.sh
./install.sh -w jeedom
