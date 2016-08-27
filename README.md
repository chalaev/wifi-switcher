<div id="table-of-contents">
<h2>Table of Contents</h2>
<div id="text-table-of-contents">
<ul>
<li><a href="#sec-1">1. Quick start</a></li>
<li><a href="#sec-2">2. Configuration examples for icewm and pdmenu</a></li>
</ul>
</div>
</div>

wifi-switcher is a simple automatic switcher between wifi networks for laptops with
[icewm](http://www.icewm.org) (window manager) or [pdmenu](https://joeyh.name/code/pdmenu/) (console menu program).
To be used as a simple replacement of [network manager](https://wiki.gnome.org/Projects/NetworkManager) or [wicd](https://launchpad.net/wicd) (simplicity often means reliability).
Also wifi-switcher can work in the wifi-server (adhoc) mode where it launches vsftpd server.
(I use this feature mainly to move photos/videos/music from/to my wife's smartphone.)

See more information in `wifi-switcher*.org` files.

# Quick start<a id="sec-1" name="sec-1"></a>

Download (or create yourself using `pack.sh`) and install [wifi-switcher\_1.0-1\_all.deb](http://chalaev.com/pub/wifi-switcher_1.0-1_all.deb):

    wget http://chalaev.com/pub/wifi-switcher_1.0-1_all.deb
    dpkg -i wifi-switcher_1.0-1_all.deb

Use configuration examples described below.  
Add networks automatically (see screenshots) or manually (edit `/etc/wpa_supplicant/wifi-switcher.conf`).
Run `/usr/share/wifi-switcher/get-passwords` to display (randomly-generated) passwords needed to connect to the adhoc wifi spot.
To change ftp and adhoc passwords or the wifi-interface name, run

    dpkg-reconfigure wifi-switcher

From time to time packages `hostapd` and `vsftpd` used by `wifi-switcher` are updated;
during the update these services are set to be launched at system start and always be active.
Use `dpkg-reconfigure wifi-switcher` to de-activate them;
`wifi-switcher` assumes that `hostapd` is running only during its "adhoc" mode and will be messed up otherwise.

# Configuration examples for icewm and pdmenu<a id="sec-2" name="sec-2"></a>

A line in my `~/.icewm/menu` file generating wifi menu is

    menuprogreload wifi - 0 /usr/bin/wifi-switcher -icewm scan --wifi-hotspot

My real-life IceWM configuration is [available here](http://chalaev.com/pub/skel/.icewm/).

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