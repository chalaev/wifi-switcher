#!/bin/bash
# requires packages: debhelper dh-make fakeroot build-essential config-package-dev

# dpkg-source --commit
# debsign wifi-switcher_1.0-1_amd64.changes
# dupload -to mentors .

if [ -e changelog.gz ] ; then rm changelog.gz ; fi
cat debian/changelog > changelog
gzip changelog

if [ -e debian/control ]; then
    projectName=$(awk "\$1==\"Package:\" {print \$2}"  debian/control)
fi
if [ -z "$projectName" ] || [ "$projectName" != "wifi-switcher" ]; then
    echo "This is a wrong directory, please change to correct one"
    exit 1
fi

if [ -e debian/${projectName} ]; then
    rm -r debian/${projectName}
fi
# remove dangling tabs left by emacs shell-script-mode:
find debian/ -type f \( -name "pre*" -o -name "post*" \) -exec sed -i "s/[ \t]\+$//" {} \;

# generate man-files from emacs org-mode ones (note that the original ox-man.el is buggy):
if [ -e /usr/share/emacs/site-lisp/org-mode/ox-man.el ]  ; then
    oxman="/usr/share/emacs/site-lisp/org-mode/ox-man.el"
    for i in ${projectName}*.org; do
	wsn=$(basename $i .org)
	emacs --no-site-file --batch ${wsn}.org -l $oxman -f org-man-export-to-man
	# the following sed fixes consequences of ox-man.el bugs:
	sed  -e "s/\\\s[+-]2//g" -e "s/\\\u//g" -e "s/\.br$/\n.br/" -e  's/^\.TH "" "1"/.TH "wifi-switcher" "1"/' -i ${wsn}.man
	mv ${wsn}.man man/
    done
fi
rm ../${projectName}_*

# https://www.debian.org/doc/debian-policy/ch-source.html#s-dpkgchangelog
# version="1.0"
# if [ -e current_version.txt ] ; then read version < current_version.txt ; else version="1.0" ; fi
version=$(dpkg-parsechangelog --show-field Version | sed "s/-[0-9]\+$//")
echo "Packaging the ${version}th version."
dh_make -p ${projectName}_${version} -c gpl -e oleg@chalaev.com --indep --yes --createorig

# dpkg-buildpackage -rfakeroot -us -uc -v$version
# dpkg-buildpackage -rfakeroot -uc -v$version
echo "will call dpkg-buildpackage now"
dpkg-buildpackage -rfakeroot -uc -koleg@chalaev.com
# See the package local-apt-repository:
# commented it out 2020-05-01:
# if [ -d /srv/local-apt-repository/ ]; then
#     cp  ../${projectName}*.deb /srv/local-apt-repository/
# fi

# Finally, I publish both on Debian and http://chalaev.com
echo "will call debsign now"
cd .. ; yes | debsign -k oleg@chalaev.com wifi-switcher_*_amd64.changes
# dupload -to mentors wifi-switcher_*_amd64.changes
# rsync -avu  wifi-switcher_* chalaevc@chalaev.com:public_html/pub/ws/
# ssh chalaevc@chalaev.com ". perms.sh"
