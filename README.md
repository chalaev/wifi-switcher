<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#orgb863285">1. Quick start</a></li>
<li><a href="#orgee545b5">2. Configuration examples for icewm and pdmenu</a></li>
</ul>
</div>
</div>
wifi-switcher is a simple automatic switcher between wifi networks for laptops with
[icewm](http://www.icewm.org) (window manager) or [pdmenu](https://joeyh.name/code/pdmenu/) (console menu program).
To be used as a simple replacement of [network manager](https://wiki.gnome.org/Projects/NetworkManager) or [wicd](https://launchpad.net/wicd) (simplicity often means reliability).
Also wifi-switcher can work in the wifi-server (adhoc) mode where it launches vsftpd server.
(I use this feature mainly to move photos/videos/music from/to my wife's smartphone.)

See more information in `wifi-switcher*.org` files.


<a id="orgb863285"></a>

# Quick start

Download (or create yourself using `pack.sh`) and install [wifi-switcher\_2.0-1\_all.deb](https://github.com/chalaev/chalaev/raw/master/pub/ws/wifi-switcher_2.0-1_all.deb)

    wget https://github.com/chalaev/chalaev/raw/master/pub/ws/wifi-switcher_2.0-1_all.deb
    dpkg -i wifi-switcher_2.0-1_all.deb

(In Debian stretch instead of `dpkg -i wifi-switcher_2.0-1_all.deb`
I use `local-apt-repository` package which makes `.deb` files stored in
`/srv/local-apt-repository/` available to standard system utilities like
`apt-get` or `aptitude`.)

Use configuration examples described below.  
Add networks automatically (see screenshots) or manually (edit `/etc/wpa_supplicant/wifi-switcher.conf`).
Run `/usr/share/wifi-switcher/get-passwords` to display (randomly-generated) passwords needed to connect to the adhoc wifi spot.
To change ftp and adhoc passwords or the wifi-interface name, run

    dpkg-reconfigure wifi-switcher

`wifi-switcher` assumes that `hostapd` is running only during its "adhoc" mode and will be messed up otherwise.
So when `wifi-switcher` there should be no `hostapd` running.
To ensure that `hostapd` and `isc-dhcp-server` are not launched at boot, disable them (as root):

    for i in $(service --status-all | grep "hostapd\|isc-dhcp-server" | awk '{print $NF}') ; do
        update-rc.d -f $i remove
    done

(You might want to disable vsftpd autostart as well.)
From time to time packages `hostapd`,  `isc-dhcp-server`, and `vsftpd` are updated and hence reconfigured to autostart again so you
may have to disable them again.

Otherwise just add

    sudo /usr/sbin/service hostapd stop

to your ~/.profile


<a id="orgee545b5"></a>

# Configuration examples for icewm and pdmenu

A line in my `~/.icewm/menu` file generating wifi menu is

    menuprogreload wifi - 0 /usr/bin/wifi-switcher -icewm scan --wifi-hotspot

My real-life IceWM configuration is [available here](https://github.com/chalaev/chalaev/tree/master/pub/skel/dot.icewm).

My `~/.pdmenu` file looks as follows:

    #!/usr/bin/pdmenu
    # Define the main menu.
    menu:main:Main Menu
    show:navit...::navit_conf
    group:wifi (_unicode)
    	exec::makemenu:\
    		echo "menu:mainWiFimenu:Choose network:Select the network" ; \
    		/usr/bin/wifi-switcher -pdmenu scan
    	show:::mainWiFimenu
    	remove:::mainWiFimenu
    endgroup
    group:wifi (_ascii)
    	exec::makemenu:\
    		echo "menu:mainWiFimenuII:Choose network:Select the network" ; \
    		/usr/bin/wifi-switcher -pdmenu scan --ascii
    	show:::mainWiFimenuII
    	remove:::mainWiFimenuII
    endgroup
    group:wifi (unicode + hotspot)
    	exec::makemenu:\
    		echo "menu:mainWiFimenu:Choose network:Select the network" ; \
    		/usr/bin/wifi-switcher -pdmenu --wifi-hotspot scan
    	show:::mainWiFimenu
    	remove:::mainWiFimenu
    endgroup
    group:wifi (ascii + hotspot)
    	exec::makemenu:\
    		echo "menu:mainWiFimenuII:Choose network:Select the network" ; \
    		/usr/bin/wifi-switcher -pdmenu scan --ascii --wifi-hotspot
    	show:::mainWiFimenuII
    	remove:::mainWiFimenuII
    endgroup
    
    # Other stuff: for example, I use (good, old, no more maintained) vux as a music player:
    show:_vux...::vux_conf
    
    menu:vux_conf:Vux:Vux
    exec:down next::vuxctl down next
    exec:pause::vuxctl pause
    exec:next::vuxctl next
    exec:up stop::vuxctl up stop
    # exec:reload::vuxctl reload

