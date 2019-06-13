#!/bin/bash
# package name from apk

hwc_install() {
    adb install -r $1
}

hwc_uninstall() {
    package=$(aapt dump badging $1 | awk '/package/{gsub("name=|'"'"'","");  print $2}')
    adb uninstall $package
}

hwc_list_packages() {
    adb shell pm list packages -f
}

hwc_show() {
    package=$(aapt dump badging $1 | awk '/package/{gsub("name=|'"'"'","");  print $2}')
    activity=$(aapt dump badging $1 | awk '/activity/{gsub("name=|'"'"'","");  print $2}')
    echo "$package"
    echo "---"
    echo "$activity"
}

hwc_run() {
    # activity=$(aapt dump badging $1 | awk '/activity/{gsub("name=|'"'"'","");  print $2}')
    # adb shell am start -n $activity

    package=$(aapt dump badging $1 | awk '/package/{gsub("name=|'"'"'","");  print $2}')
    adb shell monkey -p $package 1
}

hwc_kill() {
    package=$(aapt dump badging $1 | awk '/package/{gsub("name=|'"'"'","");  print $2}')
    adb shell am force-stop $package
}

# ------------------------------------------------------------------------------
show_usage() {
    echo "package/activity name from apk"
    echo "i       )   hwc_install $2      ;;"
    echo "u       )   hwc_uninstall $2    ;;"
    echo "l       )   hwc_list_packages   ;;"
    echo "s       )   hwc_show $2         ;;"
    echo "r       )   hwc_run $2          ;;"
    echo "k       )   hwc_kill $2         ;;"
}

if [ $# == 0 ]; then
    show_usage
    exit 0
fi

case $1 in
i       )   hwc_install $2      ;;
u       )   hwc_uninstall $2    ;;
l       )   hwc_list_packages   ;;
s       )   hwc_show $2         ;;
r       )   hwc_run $2          ;;
k       )   hwc_kill $2         ;;
*)  show_usage; exit 1
esac

exit 0
