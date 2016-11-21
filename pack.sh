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
	sed  -e "s/\\\s[+-]2//g" -e "s/\\\u//g" -e "s/\.br$/\n.br/" -i ${wsn}.man
	mv ${wsn}.man man/
    done
fi
rm ../${projectName}_*

# задача: прочитать версию из файла или из опции:
# version="1.0"
if [ -e current_version.txt ] ; then read version < current_version.txt ; else version="1.0" ; fi
version=$(echo  $version + 0.1 | bc)
while getopts v: opt ; do
    case "$opt" in
	v)  version="$OPTARG" ;;
	\?) echo "Invalid option: -$OPTARG" >&2  ;;
    esac
done
LC_NUMERIC=C version=$(printf "%1.1f" $version)
# temporary fix because for version number ≠1.0 dpkg-buildpackage below fails:
version="1.0"
echo "Packaging the ${version}th version."
dh_make -p ${projectName}_${version} -c gpl -e chalaev@gmail.com --indep --yes --createorig
echo $version > current_version.txt

# следующая строчка не работает, конфликт версий (если версия не равна 1.0)
# dpkg-buildpackage -rfakeroot -us -uc -v$version
dpkg-buildpackage -rfakeroot -uc -v$version
# See the package local-apt-repository:
if [ -d /srv/local-apt-repository/ ]; then
    cp  ../${projectName}*.deb /srv/local-apt-repository/
fi
cp ../${projectName}_* /home/www/pub/ws/
cp ../${projectName}_* current_release/
