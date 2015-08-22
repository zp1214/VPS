#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: You must be root to run this script, please use root to install lnmp"
    exit 1
fi

domain=""

. install/lamp.sh
. install/domain.sh
. install/wordpress.sh


Get_Domain()
{
    domain=""
    read -p "Input Domain Name:(example: oxthem.com)" domain
}

New_Domain()
{
    if [ "${domain}" = "" ]; then
    	echo "Domain name empty."
        Get_Domain
        New_Domain
    else
        Add_Host
    fi
}
Add_New_Domain()
{
    read -p "Create new domain:y/n" newdomain
    if [ "${newdomain}" = "n" ]; then
        exit 1
    else
        New_Domain
    fi
}

New_Wordperss()
{
    if [ "${domain}" = "" ]; then
        echo "Domain name empty."
        Get_Domain
        New_Wordperss
    else
        Install_wordpress
    fi
}
Install_Websites()
{
    read -p "Install Wordpress:y/n" newwp
    if [ "${newwp}" = "n" ]; then
        exit 1
    else
        New_Wordperss
    fi
}

Add_More_Domain()
{
    read -p "Add More Domain:y/n" moredm
    if [ "${moredm}" = "y" ]; then
        Add_New_Domain
    fi
}
Add_More_WP()
{
    read -p "Add More Wordpress:y/n" morewp
    if [ "${morewp}" = "y" ]; then
        Install_Websites
    fi
}

Install_LAMP()
{
    read -p "Install LAMP:y/n" installlamp
    if [ "${installlamp}" = "y" ]; then
        LAMP_Stack
    fi
}

Install_LAMP
Add_New_Domain
Install_Websites
Add_More_Domain
Add_More_WP