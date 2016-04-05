#!/bin/sh
if [ -e debian/control ]; then
    projectName=$(awk "\$1==\"Package:\" {print \$2}"  debian/control)
fi
if [ -z "$projectName" ] || [ "$projectName" != "wifi-switcher" ]; then
    echo "This is a wrong directory, please change to correct one"
    exit 1
fi
if [ -e debian/wifi-switcher ]; then
    rm -r debian/wifi-switcher
fi
# remove dangling tabs left by emacs shell-script-mode:
find debian/ -type f \( -name "pre*" -o -name "post*" \) -exec sed -i "s/[ \t]\+$//" {} \;
# generate man-files from emacs org-mode ones (note that the original ox-man.el is buggy):
if `ls /usr/share/emacs/*/lisp/org/ox-man.elc > /dev/null 2>&1` ; then
    oxman=$(ls /usr/share/emacs/*/lisp/org/ox-man.elc)
    oxman=$(echo "$oxman" | head -n1)
    for i in wifi-switcher*.org; do
	wsn=`basename $i .org`
	emacs  ${wsn}.org --batch -l $oxman -f org-man-export-to-man --kill
	sed -i  -e "s/\\\s[+-]2//g" -e "s/\\\u//g" ${wsn}.man
	mv ${wsn}.man man/
    done
fi
rm Packages.gz ../wifi-switcher_*
dh_make -c gpl -e chalaev@gmail.com --indep --yes --createorig
dpkg-buildpackage -rfakeroot -us -uc
# See the package local-apt-repository:
if [ -d /srv/local-apt-repository/ ]; then
    mv  ../wifi-switcher*.deb /srv/local-apt-repository/
fi
