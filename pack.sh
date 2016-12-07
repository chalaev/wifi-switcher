#!/bin/bash
# requires packages: debhelper dh-make fakeroot build-essential config-package-dev

# dpkg-source --commit
# debsign wifi-switcher_1.0-1_amd64.changes
# dupload -to mentors .

if [ -e debian/control ]; then
    projectName=$(awk "\$1==\"Package:\" {print \$2}"  debian/control)
fi
if [ -z "$projectName" ] || [ "$projectName" != "wifi-switcher" ]; then
    echo "This is a wrong directory, please change to correct one"
    exit 1
fi
find /srv/local-apt-repository/ -name "${projectName}*.deb" -exec rm {} \;
if [ -e debian/${projectName} ]; then
    rm -r debian/${projectName}
fi
# remove dangling tabs left by emacs shell-script-mode:
find debian/ -type f \( -name "pre*" -o -name "post*" \) -exec sed -i "s/[ \t]\+$//" {} \;

# generate man-files from emacs org-mode ones (note that the original ox-man.el is buggy):
#if `ls /usr/share/emacs/*/lisp/org/ox-man.elc > /dev/null 2>&1` ; then
if [ -e /usr/share/emacs/site-lisp/org-mode/ox-man.el ]  ; then
    # oxman=$(ls /usr/share/emacs/*/lisp/org/ox-man.elc)
    # oxman=$(echo "$oxman" | head -n1)
    oxman="/usr/share/emacs/site-lisp/org-mode/ox-man.el"
    for i in ${projectName}*.org; do
	wsn=`basename $i .org`
	emacs  ${wsn}.org --batch -l $oxman -f org-man-export-to-man --kill
	# the following sed fixes consequences of ox-man.el bugs:
#	sed  -e "s/\\\s[+-]2//g" -e "s/\\\u//g" -e "s/\.br$/\n.br/" -e "s/\$\\\\/\\\\\\\\/" -i ${wsn}.man
	sed  -e "s/\\\s[+-]2//g" -e "s/\\\u//g" -e "s/\.br$/\n.br/" -e  's/^\.TH "" "1"/.TH "wifi-switcher" "1"/' -i ${wsn}.man
	mv ${wsn}.man man/
    done
fi
rm ../${projectName}_*

# https://www.debian.org/doc/debian-policy/ch-source.html#s-dpkgchangelog
# version="1.0"
# if [ -e current_version.txt ] ; then read version < current_version.txt ; else version="1.0" ; fi
version=`dpkg-parsechangelog --show-field Version | sed "s/-[0-9]\+$//"`
echo "Packaging the ${version}th version."
mv -i .git ../wifi-switcher.git
mv -i .pc ../wifi-switcher.pc
dh_make -p ${projectName}_${version} -c gpl -e chalaev@gmail.com --indep --yes --createorig
mv -i  ../wifi-switcher.pc .pc
mv -i  ../wifi-switcher.git .git
# echo $version > current_version.txt

# dpkg-buildpackage -rfakeroot -us -uc -v$version
# dpkg-buildpackage -rfakeroot -uc -v$version
dpkg-buildpackage -rfakeroot -uc
# See the package local-apt-repository:
if [ -d /srv/local-apt-repository/ ]; then
    cp  ../${projectName}*.deb /srv/local-apt-repository/
fi

# Finally, I publish both on Debian and http://chalaev.com
cd .. ; yes | debsign wifi-switcher_*_amd64.changes
# dupload -to mentors wifi-switcher_*_amd64.changes
# rsync -avu  wifi-switcher_* chalaevc@chalaev.com:public_html/pub/ws/
# ssh chalaevc@chalaev.com ". perms.sh"
