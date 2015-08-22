#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ `id -u` -ne 0 ]
then
  echo "please run it by root"
  exit 0
fi

LAMP_Stack()
{
cur_dir=$(pwd)

# Installing Software Updates
apt-get update
apt-get upgrade --show-upgraded


#https://www.linode.com/docs/security/securing-your-server/
#Creating a Firewall
cp ${cur_dir}/conf/iptables.firewall.rules /etc/iptables.firewall.rules
iptables-restore < /etc/iptables.firewall.rules

# activate firewall every time you restart your Linode
cp ${cur_dir}/conf/firewall /etc/network/if-pre-up.d/firewall
chmod +x /etc/network/if-pre-up.d/firewall

#Installing and Configuring Fail2Ban
apt-get install fail2ban


#------------hosting a website-------------------
#https://www.linode.com/docs/websites/hosting-a-website/
#Installing Apache
apt-get install apache2

#Optimizing Apache for a Linode 1GB
cp /etc/apache2/apache2.conf /etc/apache2/apache2.backup.conf

sed -i "s/KeepAlive On/KeepAlive Off/g" /etc/apache2/apache2.conf
sed -i "$ a <IfModule mpm_prefork_module>" /etc/apache2/apache2.conf
sed -i "$ a StartServers 2" /etc/apache2/apache2.conf
sed -i "$ a MinSpareServers 6" /etc/apache2/apache2.conf
sed -i "$ a MaxSpareServers 12" /etc/apache2/apache2.conf
sed -i "$ a MaxClients 30" /etc/apache2/apache2.conf
sed -i "$ a MaxRequestsPerChild 3000" /etc/apache2/apache2.conf
sed -i "$ a </IfModule>" /etc/apache2/apache2.conf
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
 

#ensure that mod_rewrite is enabled
a2enmod rewrite
service apache2 restart

#Installing MySQL
apt-get install mysql-server
mysql_secure_installation

# Optimizing MySQL for a Linode 1GB
sed -i 's/#max_connections        = 100/max_connections = 75/g' /etc/mysql/my.cnf
#sed -i 's/key_buffer              = 16M/key_buffer = 32M/g' /etc/mysql/my.cnf
#sed -i 's/max_allowed_packet      = 16M/max_allowed_packet = 1M/g' /etc/mysql/my.cnf
#sed -i "s/thread_stack            = 192K/thread_stack = 128K/g" /etc/mysql/my.cnf
sed -i 's/#table_cache            = 64/table_cache = 32/g' /etc/mysql/my.cnf
service mysql restart

#Installing PHP
apt-get install php5 php-pear
apt-get install php5-mysql

#Optimizing PHP for a Linode 1GB
#Optimizing not available in current status

#Disable the default Apache virtual host
#a2dissite *default

# Create file root directory
mkdir -p /var/www

#install phpMyAdmin
apt-get install php5-mcrypt
apt-get install phpmyadmin
service apache2 restart
#Configuring phpMyAdmin
mkdir -p /var/www/html
cd /var/www/html
ln -s /usr/share/phpmyadmin

# Install Send Mail
apt-get install sendmail
apt-get install mailutils
# Run sendmail on system start
apt-get install chkconfig
chkconfig sendmail on
#enable send mail
sed -i 's#;sendmail_path =#sendmail_path = /usr/sbin/sendmail -t -i#g' /etc/php5/apache2/php.ini
service apache2 restart

# Install Unzip
apt-get install unzip

# Create PHP error log
mkdir -p /var/log/php
# user defined in /etc/apache2/envvars
# default user www-data
#chown -R ${PACHE_RUN_USER}:${APACHE_RUN_GROUP}  /var/log/php
chown -R www-data:www-data  /var/log/php

# Test Php
    cat >/var/www/html/info.php<<eof
<?php phpinfo(); ?>
eof

service apache2 restart

}