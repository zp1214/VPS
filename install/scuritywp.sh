#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ `id -u` -ne 0 ] 
then
  echo "please run it by root"
  exit 0
fi

Security_wordpress()
{
    domain=""
    read -p "Please enter domain(example: oxthem.com): " domain
    if [ "${domain}" = "" ]; then
        echo "No enter,domain name can't be empty."
        exit 1
    fi
    chown root:root /var/www/${domain}/public_html/wp-config.php
}

Security_wordpress