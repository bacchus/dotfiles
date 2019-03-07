#!/bin/bash
# package name from apk

hwc_install() {
    adb install $1
}

hwc_uninstall() {
    package=$(aapt dump badging $1 | awk '/package/{gsub("name=|'"'"'","");  print $2}')
    adb uninstall $package
}

hwc_list_packages() {
    adb shell pm list packages -f
}

hwc_start() {
    # activity=$(aapt dump badging $1 | awk '/activity/{gsub("name=|'"'"'","");  print $2}')
    # adb shell am start -n $activity

    package=$(aapt dump badging $1 | awk '/package/{gsub("name=|'"'"'","");  print $2}')
    adb shell monkey -p $package 1
}

hwc_stop() {
    package=$(aapt dump badging $1 | awk '/package/{gsub("name=|'"'"'","");  print $2}')
    adb shell am force-stop $package
}

# ------------------------------------------------------------------------------
show_usage() {
    echo "package/activity name from apk"
    echo "i       )   hwc_install $2      ;;"
    echo "u       )   hwc_uninstall $2    ;;"
    echo "l       )   hwc_list_packages   ;;"
    echo "r       )   hwc_start $2        ;;"
    echo "k       )   hwc_stop $2         ;;"
}

if [ $# == 0 ]; then
    show_usage
    exit 0
fi

case $1 in
i       )   hwc_install $2      ;;
u       )   hwc_uninstall $2    ;;
l       )   hwc_list_packages   ;;
r       )   hwc_start $2        ;;
k       )   hwc_stop $2         ;;
*)  show_usage; exit 1
esac

exit 0
