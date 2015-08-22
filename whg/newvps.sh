#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

cur_dir=$(pwd)

. lamp.sh
. domain.sh
. wordpress.sh

Imput_Domain ()
{
	domain=""
	read -p "Domain Name:" domain
}

New_Domain()
{	
	Imput_Domain
    if [ "${domain}" = "" ]; then
    	echo "No enter,domain name can't be empty."
        Imput_Domain
    else
        
    fi
}
Add_Host
Install_wordpress

LAMP_Stack


echo "======================================"

