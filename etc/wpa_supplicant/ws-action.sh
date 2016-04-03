#!/bin/sh
# originally written by Roman Galeev http://jamhed.dreamwidth.org/82198.html
# packaged by Time-stamp: <2015/07/16 11:12 EDT by Oleg SHALAEV http://chalaev.com >

IFACE="$1"
ACTION="$2"

case "$ACTION" in
        "CONNECTED")
                # logger -p daemon.info "wifi-switcher connected"
		echo "wifi-switcher connected" >> /var/log/wifi-switcher.log
                killall -USR1 udhcpc
                ;;

        "DISCONNECTED")
		echo "wifi-switcher disconnected" >> /var/log/wifi-switcher.log
                # logger -p daemon.info "wifi-switcher disconnected"
                killall -USR2 udhcpc
                ;;

        *)
                echo "Unknown action: \"$ACTION\""
                exit 1
                ;;
esac
