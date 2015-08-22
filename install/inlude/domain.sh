#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

if [ `id -u` -ne 0 ]
then
  echo "please run it by root"
  exit 0
fi

Add_Host()
{
    domain=""
    read -p "Please enter domain(example: oxthem.com): " domain
    if [ "${domain}" = "" ]; then
        echo "No enter,domain name can't be empty."
        exit 1
    fi
    if [ ! -f "/etc/apache2/sites-available/${domain}.conf" ]; then
        echo "======================================"
        echo " Your domain: ${domain}"
        echo "======================================"
    else
        echo "==============================="
        echo "${domain} is exist!"
        echo "==============================="
    fi

    hostdir="/var/www/${domain}"

    echo "Virtual Host Directory: ${hostdir}"


    echo "Create Virtul Host directory......"
    mkdir -p ${hostdir}
    mkdir -p ${hostdir}/public_html
    mkdir -p ${hostdir}/log
    mkdir -p ${hostdir}/backups
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


    echo "set permissions of Virtual Host directory......"
    chmod -R 755 ${hostdir}
    chown -R ${PACHE_RUN_USER}:${APACHE_RUN_GROUP} ${hostdir}

    cat >/etc/apache2/sites-available/${domain}.conf<<eof
# domain: ${domain}
# public: /var/www/${domain}/public_html/

<VirtualHost *:80>
  # Admin email, Server Name (domain name), and any aliases
  ServerAdmin hello@${domain}
  ServerName  www.${domain}
  ServerAlias ${domain}

  # Index file and Document Root (where the public files are located)
  DirectoryIndex index.html index.php
  DocumentRoot ${hostdir}/public_html
  # Log file locations
  LogLevel warn
  ErrorLog  ${hostdir}/log/error.log
  CustomLog ${hostdir}/log/access.log combined
</VirtualHost>
eof

    a2ensite ${domain}.conf
    service apache2 restart

    read -p "Create database(y/n):" create_database

    MySQL_Bin="/usr/bin/mysql"

    if [ "${create_database}" = "y" ]; then
        Verify_MySQL_Password
        Add_Database_Menu
        Add_Database
    fi
    echo "Test Apache configure file..."
    apachectl configtest
    echo "Restart Apache..."
    service apache2 restart

    echo "================================================"
    echo "Virtualhost infomation:"
    echo "Your domain: ${domain}"
    echo "Home Directory: ${hostdir}"
    if [ "${create_database}" = "y" ]; then
        echo "Database username: ${database_name}"
        echo "Database userpassword: ${user_password}"
        echo "Database Name: ${database_name}"
    else
        echo "Create database: no"
    fi
    echo "================================================"
    read -p "Add more domain?(y/n)" more_domain
    if [ "${more_domain}" = "y" ]; then
        Add_Host
    fi
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

Add_Database_Menu()
{
    read -p "Enter database name: " database_name
    if [ "${database_name}" = "" ]; then
        echo "Database Name can't be empty!"
        exit 1
    fi
    echo "Your will create a database name: ${database_name}"
    read -p "Please enter mysql user name for database: " user_name
    if [ "${user_name}" = "" ]; then
        echo "User Name can't be empty!"
        exit 1
    fi
    read -p "Please enter password for mysql user ${user_name}: " user_password
    if [ "${user_password}" = "" ]; then
        echo "Password can't be empty!"
        exit 1
    fi
    echo "Your name: ${user_name} "
    echo "Your password: ${user_password} "
}

Add_Database()
{
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "CREATE USER '${user_name}'@'127.0.0.1' IDENTIFIED BY '${user_password}'"
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "CREATE USER '${user_name}'@'localhost' IDENTIFIED BY '${user_password}'"
    [ $? -eq 0 ] && echo "User ${user_name} create Sucessfully." || echo "User ${user_name} already exists!"
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "GRANT USAGE ON *.* TO '${user_name}'@'127.0.0.1' IDENTIFIED BY '${user_password}'"
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "GRANT USAGE ON *.* TO '${user_name}'@'localhost' IDENTIFIED BY '${user_password}'"
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "CREATE DATABASE ${database_name}"
    [ $? -eq 0 ] && echo "Database: ${database_name} create Sucessfully." || echo "Database: ${database_name} already exists!"
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "GRANT ALL PRIVILEGES ON ${database_name}.* TO '${user_name}'@'127.0.0.1';"
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "GRANT ALL PRIVILEGES ON ${database_name}.* TO '${user_name}'@'localhost';"
    [ $? -eq 0 ] && echo "GRANT ALL PRIVILEGES ON ${database_name} Sucessfully." || echo "GRANT ALL PRIVILEGES ON ${database_name} failed!"
    ${MySQL_Bin} -uroot -p${mysql_root_password} -e "FLUSH PRIVILEGES"
    [ $? -eq 0 ] && echo "FLUSH PRIVILEGES Sucessfully." || echo "FLUSH PRIVILEGES failed!"
}