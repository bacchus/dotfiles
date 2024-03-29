#!/bin/bash

PATH="$workspace/out/host/linux-x86/bin:$PATH"

BCC_COLOR="-v color"

# ------------------------------------------------------------------------------
test_cl() {
    echo "$(tput setab 4) --- clear logcat --- $(tput sgr0)"
    adb logcat -c
}

test_all() {
    echo "$(tput setab 4) --- all logcat [${@:1}] {~/logs/all-logcat.txt} --- $(tput sgr0)"
    adb logcat ${@:1} $BCC_COLOR | tee ~/logs/all-logcat.txt
}

test_hwc() {
    test_target='hwcomposer android.hardware.automotive.evs@1.0.salvator BCC EVSAPP EvsApp EvsManager SurfaceFlinger'

    echo "$(tput setab 4) --- all logcat [$test_target] {~/logs/hwc-logcat.txt} --- $(tput sgr0)"
    adb logcat -s $test_target $BCC_COLOR | tee ~/logs/hwc-logcat.txt
}

test_strip() {

    test_file=$1
    if [[ $1 = "hwc" ]]; then
        test_file="~/logs/hwc-logcat.txt"
    elif [[ $1 = "all" ]]; then
        test_file="~/logs/all-logcat.txt"
    fi

    echo "$(tput setab 4) --- strip [$1] {$test_file} --- $(tput sgr0)"

    awk '!($1=$2=$3=$4="")' $test_file | awk '{$1=$1}1' | sed -r "s/[[:cntrl:]]\[[0-9]{1,3}m//g" > $test_file.tmp
    rm -f $test_file.bak && mv $test_file{,.bak} && mv $test_file{.tmp,}
}

test_re() {
    echo "$(tput setab 4) --- restart adb --- $(tput sgr0)"
    adb kill-server
    adb devices
}

# ------------------------------------------------------------------------------
show_usage() {
    echo "cl        )   logcat clear        "
    echo "all [*]   )   all-logcat [*]      "
    echo "hwc       )   hwc                 "
    echo "str [all,hwc,<path>] ) strip [target]  "
    echo "re        )   test_re             "
}

if [ $# == 0 ]; then
    show_usage
    exit 0
fi

case $1 in
cl      )   test_cl         ;;
all     )   test_all ${@:2} ;;
hwc     )   test_hwc        ;;
str     )   test_strip $2   ;;
re      )   test_re         ;;
*       )   test_all -s $1 ${@:2} ;;
esac

exit 0
