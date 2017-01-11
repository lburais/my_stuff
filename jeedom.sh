###########################################################################################################################################
# Dependencies
###########################################################################################################################################

apt-get -y update
apt-get -y upgrade

apt-get install -y gcc-4.9 g++-4.9 ncurses-dev make git 
update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 50
update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-4.9 50

apt-get install -y rpi-update
apt-get -y dist-upgrade

###########################################################################################################################################
# RPi source
###########################################################################################################################################

wget https://raw.githubusercontent.com/notro/rpi-source/master/rpi-source -O /usr/local/bin/rpi-source
chmod +x /usr/local/bin/rpi-source
rpi-source -q --tag-update
rpi-source

###########################################################################################################################################
# RPUSBDISP
###########################################################################################################################################

mkdir -p /root/robopeak
cd /root/robopeak

wget get.pimoroni.com/kernel7-rpusb.img
#sudo cp kernel7-rpusb.img /boot/

wget get.pimoroni.com/modules.tar.gz
tar -zxf modules.tar.gz
#sudo mv 3.19.2-v7+/ /lib/modules

sed -i -e “$akernel=kernel7-rpusb.img” /boot/config.txt
sed -i -e “$arp_usbdisplay” /etc/modules

# To verify that the display is working, throw some random data at it:
# cat /dev/urandom > /dev/fb1

###########################################################################################################################################
# JEEDOM
###########################################################################################################################################

mkdir -p /var/www/jeedom
rm -rf /root/core-*
wget https://github.com/jeedom/core/archive/stable.zip -O /tmp/jeedom.zip
unzip -q /tmp/jeedom.zip -d /root/
cp -R /root/core-*/* /var/www/jeedom/
cp -R /root/core-*/.htaccess /var/www/jeedom/

###########################################################################################################################################
# JEEDOM AND NGINX
###########################################################################################################################################

wget https://raw.githubusercontent.com/jeedom/core/stable/install/nginx_default -O /etc/nginx/sites-available/jeedom
sed -i “s/\/var\/www\/html/\/var\/www\/jeedom/g” /etc/nginx/sites-available/jeedom
ln -s /etc/nginx/sites-available/jeedom /etc/nginx/sites-enabled/jeedom

systemctl restart php5-fpm
systemctl restart nginx

###########################################################################################################################################
# JEEDOM AND CRON
###########################################################################################################################################

echo "* * * * * su --shell=/bin/bash - www-data -c '/usr/bin/php /var/www/jeedom/core/php/jeeCron.php' >> /dev/null" | crontab -
echo "www-data ALL=(ALL) NOPASSWD: ALL" | (EDITOR="tee -a" visudo)

###########################################################################################################################################
# JEEDOM CONFIGURATION
###########################################################################################################################################

echo “http://raspberrypi/jeedom”

###########################################################################################################################################
# OPENJABNAB
###########################################################################################################################################

# apt-get install qt4-dev-tools

wget https://github.com/OpenJabNab/OpenJabNab/archive/master.zip -O /tmp/openjabnab.zip
unzip -q /tmp/openjabnab.zip -d /root/
cd /root/OpenJabNab-master
cd server
make -r
make

cp openjabnab.ini-dist bin/openjabnab.ini
sed -i “s/StandAloneAuthBypass = false/StandAloneAuthBypass = true/g” bin/openjabnab.ini
sed -i “s/AllowAnonymousRegistration = false/AllowAnonymousRegistration = true/g” bin/openjabnab.ini
sed -i “s/AllowUserManageBunny = false/AllowUserManageBunny = true/g” bin/openjabnab.ini
sed -i “s/AllowUserManageZtamp = false/AllowUserManageZtamp = true/g” bin/openjabnab.ini
sed -i “s/my.domain.com/raspberrypi/g” bin/openjabnab.ini

cp -R /root/OpenJabNab-master/* /var/www/ojn/
chmod 0777 /var/www/ojn/http-wrapper/ojn_admin/include

###########################################################################################################################################
# OPENJABNAB AND NGINX
###########################################################################################################################################

wget https://raw.githubusercontent.com/OpenJabNab/OpenJabNab/master/README.nginx -O /etc/nginx/sites-available/openjabnab
sed -i “s/\/var\/htdocs\/openjabnab/\/var\/www\/openjabnab/g” /etc/nginx/sites-available/openjabnab
ln -s /etc/nginx/sites-available/openjabnab /etc/nginx/sites-enabled/openjabnab

systemctl restart php5-fpm
systemctl restart nginx


###########################################################################################################################################
# OPENJABNAB CONFIGURATION
###########################################################################################################################################

echo “http://raspberrypi/ojn_admin/install.php”
echo “./var/www/ojn/server/bin/openjabnab”
echo “http://raspberrypi/ojn_admin/index.php”

