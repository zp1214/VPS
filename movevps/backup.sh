#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ `id -u` -ne 0 ]
then
  echo "please run it by root"
  exit 0
fi

Backup_Plugin_List ()
{
  plugindir="/var/www/${domain}/public_html/wp-content/plugins/"
  pluginlist=`ls  ${plugindir}|grep -vE "index.php|akismet"`
  cat >/var/www/html/backup/${domain}/pluginlist/plugins.txt<<eof
${pluginlist}
eof
}
Backup_Plugin ()
{
  plugindir="/var/www/${domain}/public_html/wp-content/plugins/"
  for pluginname in `ls ${plugindir}|grep -vE "index.php|akismet|hello.php"`
  do
    cp -r ${plugindir}/${pluginname} /var/www/html/backup/${domain}/pluginlist
  done
  cd /var/www/html/backup/${domain}/pluginlist
  tar -cvf plugins.tar.gz ./
}

Backup_Upload_Images ()
{
  mkdir -p /var/www/${domain}/public_html/wp-content/uploads
  cd /var/www/${domain}/public_html/wp-content/uploads
  tar -cvf image.tar.gz ./
  mv -f image.tar.gz  /var/www/html/backup/${domain}/image/image.tar.gz
}

Backup_WPconfig ()
{
  cd /var/www/${domain}/public_html
  cp -pf wp-config.php /var/www/html/backup/${domain}/wpconfig
}

Backup_Themes ()
{
  theme="/var/www/${domain}/public_html/wp-content/themes/"
  for themelist in `ls ${theme}|grep -vE "index.php|twentytwelve|twentyfifteen|twentyfourteen|twentythirteen|twentyeleven"`
  do
    cp -r ${theme}/${themelist} /var/www/html/backup/${domain}/themes
  done
  cd /var/www/html/backup/${domain}/themes
  tar -cvf themes.tar.gz ./
}

Backup_File()
{
  clear
  cd /var/www
  for domain in `ls|grep -vE "html"`
  do
    mkdir -p /var/www/html/backup/${domain}
    cd /var/www/html/backup/${domain}
    mkdir -p wpconfig
    mkdir -p pluginlist
    mkdir -p image
    mkdir -p themes
    Backup_WPconfig
    Backup_Plugin
    Backup_Plugin_List
    Backup_Upload_Images
    Backup_Themes
  done
  rm -rf /var/www/html/backup/sql
  rm /var/www/html/backup/sql.tar.gz
  cd /var/www/html/backup/
  tar -cvf backup.tar.gz ./
}

Get_Acess()
{
  read -p "MySQL ROOT Password:" rootpassword
}

Backup_SQL()
{
  Get_Acess
  mkdir -p /var/www/html/backup/sql
  cd /var/www/html/backup/sql
  #Get Database List
  mysqldata=`mysql -hlocalhost -uroot -p${rootpassword} -e"show databases"|grep -vE "mysql|information_schema|performance_schema|phpmyadmin|Database"`
  for i in ${mysqldata} ; do
    mysqldump -hlocalhost -p${rootpassword} ${i} -uroot >${i}.sql
  done
    tar -cvf sql.tar.gz ./
    mv sql.tar.gz /var/www/html/backup
}

Backup_File
Backup_SQL