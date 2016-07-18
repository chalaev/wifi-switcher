#!/bin/sh
# starts and stops hotspot for the wifi-switcher package
wifi_interface="wlan0"
essid=`hostname`
[ -r /etc/default/wifi-switcher ] && . /etc/default/wifi-switcher

case "$1" in
start)
    sudo /usr/sbin/service wifi-switcher stop
    # not needed: sudo /sbin/ifdown ${wifi_interface}
    sudo /sbin/ifup ${wifi_interface}=wifiswitcher
    for i in hostapd isc-dhcp-server vsftpd; do
	echo "starting $i"
	sudo /usr/sbin/service $i start
    done
    ;;
stop)
    for i in hostapd isc-dhcp-server vsftpd; do
	echo "stopping $i"
	sudo /usr/sbin/service $i stop
    done
    # if we do not kill dhcp server, it might be erroneously used for obtaining IP address
    # instead of (perhaps slow) dhcp server provided by the wifi network:
    [ -f /run/dhcpd.pid ] && kill $(cat /run/dhcpd.pid) && rm /run/dhcpd.pid
    sudo /sbin/ifdown ${wifi_interface}
    sudo /usr/sbin/service wifi-switcher start
;;

info)
    echo "Use \"dpkg-reconfigure wifi-switcher\" to change the settings"
    if [ -r /etc/hostapd/wifi-switcher.conf ] ; then
	awk -F= '$1 == "ssid" {print "The SSID of the hotspot wifi network is "$2}' /etc/hostapd/wifi-switcher.conf
	awk -F= '$1 == "wpa_passphrase" {print "The wpa2-passsword for the hotspot wifi network is "$2}' /etc/hostapd/wifi-switcher.conf
	echo "Run /usr/share/wifi-switcher/get-passwords as root to see the ftp password"
    else
	echo "can not read /etc/hostapd/wifi-switcher.conf, consider running me with root priviledges"
    fi
    
    echo "When you enter the hotspot mode, find out the server address from the \"hostname -I\" command"
    # now we examine existing wifi networks.
    # TO BE TESTED in case when there are no wifi networks
    csu=$(sudo /sbin/iwlist ${wifi_interface} scan | grep Channel: | sed "s/[ \t]*Channel:\([0-9]\+\)/\1/"  | sort -n)
    echo "The following wifi channels are in use"
    ucsu=$(echo "$csu" | uniq); echo $ucsu
    echo "these channels are used respectively by so many wifi networks:"
    for i in $ucsu ; do echo "$csu" | grep "^$i$" | wc -l ; done
    echo "If your devices experience problems connecting to your hotspot, consider setting a (the least used) channel number in /etc/network/interfaces.d/wifi-switcher"
    ;;
*)
    echo $"Usage: $0 {start|stop|info}"
    exit 1
esac
