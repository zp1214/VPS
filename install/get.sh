#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ `id -u` -ne 0 ]
then
  echo "please run it by root"
  exit 0
fi

Get ()
{
	mkdir -p /var/tmp/lamp
	cd /var/tmp/lamp
	wget http://52.11.217.173/lamp/lamp.tar.gz
	tar -xvf lamp.tar.gz
}
Get