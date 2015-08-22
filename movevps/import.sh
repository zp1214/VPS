#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ `id -u` -ne 0 ]
then
  echo "please run it by root"
  exit 0
fi

Install_wordpress()
{
    mkdir -p ${hostdir}/public_html/src
    cd ${hostdir}/public_html/src
    wget http://wordpress.org/latest.tar.gz
    tar -xvf latest.tar.gz
    rm latest.tar.gz
    cp -R wordpress/* ${hostdir}/public_html/
    cd ${hostdir}/public_html
    rm -rf src
    cd wp-content/themes
    for theme_name in `ls|grep -vE "index.php"`
    do
        rm -rf ${theme_name}
    done
    cd /var/www/
    for adomain in `ls|grep -vE "html"`
    do
        sed -i "$ a define('FS_METHOD', 'direct');" ${adomain}/public_html/wp-config.php
    done
}

Import_File()
{
	mkdir -p /var/www/html/import
	cd /var/www/html/import
	read -p "IP Address:(198.168.1.1)" ip
	wget http://${ip}/backup/backup.tar.gz
	tar -xvf backup.tar.gz ./
    rm backup.tar.gz

	fileroot="/var/www/html/import"
	cd ${fileroot}
	for importdomain in `ls|grep -vE "sql"`
	do
		hostdir="/var/www/${importdomain}"
		Add_Host
		Install_wordpress

		mkdir -p /var/www/${importdomain}/public_html/wp-content/uploads
		cd /var/www/html/import/${importdomain}/image
		cp -R image.tar.gz /var/www/${importdomain}/public_html/wp-content/uploads
		cd /var/www/${importdomain}/public_html/wp-content/uploads
		tar -xvf image.tar.gz
		rm image.tar.gz


        cd /var/www/html/import/${importdomain}/themes
        cp -R themes.tar.gz /var/www/${importdomain}/public_html/wp-content/themes
        cd /var/www/${importdomain}/public_html/wp-content/themes
        tar -xvf themes.tar.gz
        rm themes.tar.gz


        cd /var/www/html/import/${importdomain}/pluginlist
        cp -R plugins.tar.gz /var/www/${importdomain}/public_html/wp-content/plugins
        cd /var/www/${importdomain}/public_html/wp-content/plugins
        tar -xvf plugins.tar.gz
        rm plugins.tar.gz


		cd /var/www/html/import/${importdomain}/wpconfig
		cp -pf wp-config.php /var/www/${importdomain}/public_html
		chmod -R 755 /var/www/${importdomain}/public_html/wp-content
		chown -R www-data:www-data /var/www/${importdomain}/public_html/wp-content
        chmod -R 644 /var/www/${importdomain}/public_html/wp-config.php
		chown root:root /var/www/${importdomain}/public_html/wp-config.php
	done
	echo "Test Apache configure file..."
    rm -rf /var/www/html/import
    apachectl configtest
	service apache2 restart
}

Get_User_Info()
{
    read -p "Please enter mysql user name for database: " user_name
    if [ "${user_name}" = "" ]; then
        echo "User Name can't be empty!"
        Get_User_Info
    fi
    read -p "Please enter password for mysql user ${user_name}: " user_password
    if [ "${user_password}" = "" ]; then
        echo "Password can't be empty!"
        Get_User_Info
    fi
    echo "Your name: ${user_name} "
    echo "Your password: ${user_password} "
}

Create_SQL_User()
{
	Get_User_Info
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "CREATE USER '${user_name}'@'127.0.0.1' IDENTIFIED BY '${user_password}'"
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "CREATE USER '${user_name}'@'localhost' IDENTIFIED BY '${user_password}'"
    [ $? -eq 0 ] && echo "User ${user_name} create Sucessfully." || echo "User ${user_name} already exists!"
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "GRANT USAGE ON *.* TO '${user_name}'@'127.0.0.1' IDENTIFIED BY '${user_password}'"
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "GRANT USAGE ON *.* TO '${user_name}'@'localhost' IDENTIFIED BY '${user_password}'"
}

Create_SQL()
{
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "CREATE DATABASE ${dbname}"
    [ $? -eq 0 ] && echo "Database: ${dbname} create Sucessfully." || echo "Database: ${dbname} already exists!"
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${user_name}'@'127.0.0.1';"
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "GRANT ALL PRIVILEGES ON ${dbname}.* TO '${user_name}'@'localhost';"
    [ $? -eq 0 ] && echo "GRANT ALL PRIVILEGES ON ${dbname} Sucessfully." || echo "GRANT ALL PRIVILEGES ON ${dbname} failed!"
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "FLUSH PRIVILEGES"
    [ $? -eq 0 ] && echo "FLUSH PRIVILEGES Sucessfully." || echo "FLUSH PRIVILEGES failed!"
}
Move_SQL()
{
    mkdir -p /var/www/html/import/sql
    cd /var/www/html/import/sql
    wget http://${ip}/backup/sql.tar.gz
    tar -xvf sql.tar.gz ./
    rm sql.tar.gz
}
Verify_MySQL_Password()
{
    read -p "verify your current MySQL root password:" mysql_root_password
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "quit"
    if [ $? -eq 0 ]; then
        echo "MySQL root password correct."
    else
        echo "MySQL root password incorrect!Please check!"
        Verify_MySQL_Password
    fi
    if [ "${mysql_root_password}" = "" ]; then
        Verify_MySQL_Password
    fi
}
Upload_SQL()
{
    mkdir -p /var/www/html/import
	MySQL_Bin="/usr/bin/mysql"
	Verify_MySQL_Password
    Move_SQL
    Create_SQL_User
    cd /var/www/html/import/sql
    for sql_name in `ls`
    do
        dbname="${sql_name%%.sql}"
        Create_SQL
        mysql -hlocalhost -uroot -p${mysql_root_password} ${dbname} < ${sql_name}
    done

    echo "All sql is done!"
    rm -rf /var/www/html/import
    service apache2 restart
}

Add_Host()
{
    echo "Virtual Host Directory: ${hostdir}"
    echo "Create Virtul Host directory......"
    mkdir -p ${hostdir}/log
    mkdir -p ${hostdir}/backups
    mkdir -p ${hostdir}/public_html
    echo "Create .htaccess file"
    cat >${hostdir}/public_html/.htaccess<<eof
<IfModule mod_rewrite.c>
    RewriteEngine On
    RewriteBase /
    RewriteCond %{REQUEST_FILENAME} !-f
    RewriteCond %{REQUEST_FILENAME} !-d
    RewriteRule . /index.php [L]
</IfModule>
eof
    chmod -R 644 ${hostdir}/public_html/.htaccess
    cat >/etc/apache2/sites-available/${importdomain}.conf<<eof
# importdomain: ${importdomain}
# public: /var/www/${importdomain}/public_html/

<VirtualHost *:80>
  # Admin email, Server Name (importdomain name), and any aliases
  ServerAdmin hello@${importdomain}
  ServerName  www.${importdomain}
  ServerAlias ${importdomain}

  # Index file and Document Root (where the public files are located)
  DirectoryIndex index.html index.php
  DocumentRoot ${hostdir}/public_html
  # Log file locations
  LogLevel warn
  ErrorLog  ${hostdir}/log/error.log
  CustomLog ${hostdir}/log/access.log combined
</VirtualHost>
eof

    a2ensite ${importdomain}.conf
}
Import_File
Upload_SQL