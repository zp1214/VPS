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
apt-get -y update
apt-get -y upgrade --show-upgraded


#https://www.linode.com/docs/security/securing-your-server/
#Creating a Firewall

cat >/etc/iptables.firewall.rules<<eof
*filter

#  Allow all loopback (lo0) traffic and drop all traffic to 127/8 that doesn't use lo0
-A INPUT -i lo -j ACCEPT
-A INPUT -d 127.0.0.0/8 -j REJECT

#  Accept all established inbound connections
-A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#  Allow all outbound traffic - you can modify this to only allow certain traffic
-A OUTPUT -j ACCEPT

#  Allow HTTP and HTTPS connections from anywhere (the normal ports for websites and SSL).
-A INPUT -p tcp --dport 80 -j ACCEPT
-A INPUT -p tcp --dport 443 -j ACCEPT

#  Allow SSH connections
#
#  The -dport number should be the same port number you set in sshd_config
#
-A INPUT -p tcp -m state --state NEW --dport 22 -j ACCEPT

#  Allow ping
-A INPUT -p icmp --icmp-type echo-request -j ACCEPT

#  Log iptables denied calls
-A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7

#  Drop all other inbound - default deny unless explicitly allowed policy
-A INPUT -j DROP
-A FORWARD -j DROP

COMMIT
eof
iptables-restore < /etc/iptables.firewall.rules

# activate firewall every time you restart your VPS
cat >/etc/network/if-pre-up.d/firewall<<eof
#!/bin/sh
/sbin/iptables-restore < /etc/iptables.firewall.rules
eof
chmod +x /etc/network/if-pre-up.d/firewall

#Installing and Configuring Fail2Ban
apt-get -y install fail2ban


#------------hosting a website-------------------
#https://www.linode.com/docs/websites/hosting-a-website/
#Installing Apache
apt-get -y install apache2

#Optimizing Apache for a Linode 1GB
cp /etc/apache2/apache2.conf /etc/apache2/apache2.backup.conf
sed -i "$ a ServerName localhost" /etc/apache2/apache2.conf
sed -i "s/KeepAlive On/KeepAlive Off/g" /etc/apache2/apache2.conf
sed -i "$ a <IfModule mpm_prefork_module>" /etc/apache2/apache2.conf
sed -i "$ a StartServers 2" /etc/apache2/apache2.conf
sed -i "$ a MinSpareServers 6" /etc/apache2/apache2.conf
sed -i "$ a MaxSpareServers 12" /etc/apache2/apache2.conf
sed -i "$ a MaxClients 30" /etc/apache2/apache2.conf
sed -i "$ a MaxRequestsPerChild 3000" /etc/apache2/apache2.conf
sed -i "$ a </IfModule>" /etc/apache2/apache2.conf
sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf

echo "localhost" > /etc/HOSTNAME
hostname -F /etc/HOSTNAME

#create mod_expires Cache strategy
cat >/etc/apache2/mods-available/expires.conf<<eof
<IfModule mod_expires.c>
    ExpiresActive on
    ExpiresDefault A600
    ExpiresByType image/x-icon A2592000
    ExpiresByType application/x-javascript A604800
    ExpiresByType application/javascript A604800
    ExpiresByType text/css A604800
    ExpiresByType image/gif A2592000
    ExpiresByType image/png A2592000
    ExpiresByType image/jpeg A2592000
    ExpiresByType text/plain A86400
    ExpiresByType application/x-shockwave-flash A2592000
    ExpiresByType video/x-flv A2592000
    ExpiresByType application/pdf A2592000
    ExpiresByType text/html A600
</IfModule>
eof

#ensure that mod_rewrite is enabled for Worpdress permernant links
a2enmod rewrite
#ensure that mod_deflate is enabled for GZIP
a2enmod deflate
#ensure that mod_expires is enabled for Cache
a2enmod expires

service apache2 restart

#Installing MySQL
apt-get -y install mysql-server
mysql_secure_installation

# Optimizing MySQL for a Linode 1GB
sed -i 's/#max_connections        = 100/max_connections = 75/g' /etc/mysql/my.cnf
#sed -i 's/key_buffer              = 16M/key_buffer = 32M/g' /etc/mysql/my.cnf
#sed -i 's/max_allowed_packet      = 16M/max_allowed_packet = 1M/g' /etc/mysql/my.cnf
#sed -i "s/thread_stack            = 192K/thread_stack = 128K/g" /etc/mysql/my.cnf
sed -i 's/#table_cache            = 64/table_cache = 32/g' /etc/mysql/my.cnf
service mysql restart

#Installing PHP
apt-get -y install php5 php-pear
apt-get -y install php5-mysql

#Optimizing PHP for a Linode 1GB
#Optimizing not available in current status

#Disable the default Apache virtual host
#a2dissite *default

# Create file root directory
mkdir -p /var/www

#install phpMyAdmin
apt-get -y install php5-mcrypt
apt-get -y install phpmyadmin
php5enmod mcrypt
service apache2 restart
#Configuring phpMyAdmin
mkdir -p /var/www/html
cd /var/www/html
ln -s /usr/share/phpmyadmin

# Install Send Mail
#http://unix.stackexchange.com/questions/1551/what-is-sendmail-referring-to-here
apt-get -y install sendmail
apt-get -y install mailutils
# Run sendmail on system start
apt-get -y install chkconfig
chkconfig sendmail on
#enable send mail
sed -i 's#;sendmail_path =#sendmail_path = /usr/sbin/sendmail -t -i#g' /etc/php5/apache2/php.ini
service apache2 restart

# Install Unzip
apt-get -y install unzip

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
LAMP_Stack