#!/bin/sh
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

# Check if user is root
if [ `id -u` -ne 0 ]
then
  echo "please run it by root"
  exit 0
fi

PPTP ()
{

	apt-get -y install pptpd

	sed -i 's/#localip 192.168.0.1/localip 192.168.9.1/g' /etc/pptpd.conf
	sed -i 's/#remoteip 192.168.0.234-238,192.168.0.245/remoteip 192.168.9.11-30/g' /etc/pptpd.conf


	sed -i 's/#ms-dns 10.0.0.1/ms-dns 8.8.8.8/g' /etc/ppp/pptpd-options
	sed -i 's/#ms-dns 10.0.0.2/ms-dns 8.8.4.4/g' /etc/ppp/pptpd-options

	sed -i "$ a zp1214 pptpd test *" /etc/ppp/chap-secrets

	sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
	/sbin/sysctl -p

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

# Ebable PPTP ports
-A INPUT -i eth0 -p tcp --dport 1723 -j ACCEPT
-A INPUT -i eth0 -p gre -j ACCEPT
-A FORWARD -i ppp+ -o eth0 -j ACCEPT
-A FORWARD -i eth0 -o ppp+ -j ACCEPT

#  Drop all other inbound - default deny unless explicitly allowed policy
-A INPUT -j DROP
-A FORWARD -j DROP

COMMIT

*nat
-A POSTROUTING -o eth0 -j MASQUERADE

COMMIT
eof
iptables-restore < /etc/iptables.firewall.rules

	rm /etc/rc.local
	cat >/etc/rc.local<<eof
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

exit 0
eof

service pptpd restart

}
PPTP