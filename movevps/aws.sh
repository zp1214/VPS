#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ `id -u` -ne 0 ]
then
  echo "please run it by root"
  exit 0
fi


Backup_File()
{
	mkdir -p /var/www/html/backup/
	cd /var/www/html/backup/
	read -p "IP Address:(198.168.1.1)" ip
	wget http://${ip}/backup/backup.tar.gz
	wget http://${ip}/backup/sql.tar.gz
}
Backup_File