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
    domain=""
    read -p "Please enter domain(example: oxthem.com): " domain
    if [ "${domain}" = "" ]; then
        echo "No enter,domain name can't be empty."
        exit 1
    fi
    hostdir="/var/www/${domain}"
    mkdir -p ${hostdir}/public_html/src
    cd ${hostdir}/public_html/src
    wget http://wordpress.org/latest.tar.gz
    tar -xvf latest.tar.gz
    rm latest.tar.gz
    cp -R wordpress/* ${hostdir}/public_html/
    cd ${hostdir}/public_html
    rm -rf src
    chown -R www-data:www-data ${hostdir}
}