#/bin/bash


# ------ Jeedom install -----
# port 22 mapped to 30022
# port 80 mapped to 30080
# port 3306 mapped to 33306

apt-get update
apt-get upgrade
apt-get install wget readline-common dialog supervisor nano usbutils

echo "[supervisord]" > /etc/supervisor/conf.d/supervisord.conf
echo "nodaemon=true" >> /etc/supervisor/conf.d/supervisord.conf

echo "[program:cron]" >> /etc/supervisor/conf.d/supervisord.conf
echo "command = /usr/sbin/cron -f" >> /etc/supervisor/conf.d/supervisord.conf
echo "user = root" >> /etc/supervisor/conf.d/supervisord.conf
echo "autostart = true" >> /etc/supervisor/conf.d/supervisord.conf

echo "[program:apache2]" >> /etc/supervisor/conf.d/supervisord.conf
echo 'command=/bin/bash -c "source /etc/apache2/envvars && exec /usr/sbin/apache2 -DFOREGROUND" >> /etc/supervisor/conf.d/supervisord.conf' >> /etc/supervisor/conf.d/supervisord.conf
echo "autorestart=true" >> /etc/supervisor/conf.d/supervisord.conf

echo "[program:mysql]" >> /etc/supervisor/conf.d/supervisord.conf
echo "command=/usr/bin/pidproxy /var/run/mysqld/mysqld.pid /usr/sbin/mysqld" >> /etc/supervisor/conf.d/supervisord.conf
echo "autorestart=true" >> /etc/supervisor/conf.d/supervisord.conf

echo "#!/bin/bash" > /root/init.sh
echo "/usr/bin/supervisord" >> /root/init.sh

wget https://raw.githubusercontent.com/jeedom/core/stable/install/install.sh
chmod +x install.sh
./install.sh
