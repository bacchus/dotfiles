#!/bin/bash

ADB=$(which adb)
if [[ -z ${ADB} ]]; then
    echo "$(tput setab 3) adb not found runing source-lunch $(tput sgr0)"
    hwc-source-lunch
fi

adb_wait_device() {
    ${ADB} wait-for-device

    A=0
    while [ "$A" != "1" ]; do
        sleep 1
        A=$(${ADB} shell getprop sys.boot_completed | tr -d '\r')
    done
}

test_apis() {
    echo "$(tput setab 4) --- lunch com.example.android.apis --- $(tput sgr0)"
    adb shell monkey -p com.example.android.apis -c android.intent.category.LAUNCHER 1
    sleep 1
    adb shell input tap 50 350
    sleep 1
    adb shell input roll 0 20
    sleep 1
    adb shell input tap 50 850
    sleep 1
    adb shell input tap 50 500
}

test_hameleon() {
    echo "$(tput setab 4) --- lunch OGLES2ChameleonMan --- $(tput sgr0)"
    adb shell am start com.powervr.OGLES2ChameleonMan/.OGLES2ChameleonMan
}

test_water() {
    echo "$(tput setab 4) --- lunch OGLES3Water --- $(tput sgr0)"
    adb shell am start com.powervr.OGLES3Water/.OGLES3Water
}

test_loop() {
    echo "$(tput setab 4) --- lunch LOOP ${@:1} --- $(tput sgr0)"

    while sleep 1;
    do
        tput clear; tput sc; tput cup 0 0;

        ${@:1};

        tput rc;
    done

    #for ((i=1; i<100; i++)); do
    #echo RUN № $i
    #adb shell am start com.powervr.OGLES2ChameleonMan/.OGLES2ChameleonMan
    #adb shell 'cat /d/ion/heaps/rcar\ custom' >> ~/logs/start.cham10.txt
    #adb shell sleep 6
    #adb shell am force-stop com.powervr.OGLES2ChameleonMan
    #adb shell input keyevent BACK
    #done
}

test_cubes() {
    echo "$(tput setab 4) --- lunch cubes test --- $(tput sgr0)"
    adb shell input tap 1500 1050   # kitchen
    sleep 1
    adb shell input tap 1000 200    # tap sink anyway
    sleep 1
    adb shell input swipe 10 500 500 500    # menu
    sleep 1
    adb shell input roll 0 10       # roll
    sleep 1
    adb shell input roll 0 10       # roll to cubes test
    sleep 1
    adb shell input tap 500 950     # cubes test
}

test_auto() {
    adb shell input tap 1800 1050               # auto
    sleep 2
    adb shell input swipe 1800 500 1800 1000    # back
}

test_bccatomic() {
    crtc=1
    if [ $# != 0 ]; then
        crtc=$1
    fi

    echo "$(tput setab 4) --- bccatomictest crtc $crtc --- $(tput sgr0)"
    adb shell /system/bin/bccatomictest -c0 -r$crtc
}

test_monkey() {
    adb shell monkey -p com.example.android.apis 1000000
}

test_fps() {
    fps_enabled=1
    if [ $# != 0 ]; then
        fps_enabled=$1
    fi

    echo "$(tput setab 4) --- fps enabled: $fps_enabled --- $(tput sgr0)"
    adb shell setprop "debug.hwc.showfps" $fps_enabled
}

test_scrn() {
    echo "$(tput setab 4) --- hwc-screenshot.sh [disp] [coment] --- $(tput sgr0)"

    disp=0
    if [ $# -gt 0 ]; then
        disp=$1
    fi

    if [ $# -gt 1 ]; then
        file_coment="_$2"
    fi

    date_time=`date +%m-%d_%H-%M-%S`
    file_name=/sdcard/$date_time"_d"$disp$file_coment.png
    cur=`pwd`

    adb shell screencap -d $disp -p $file_name
    res=$?
    adb pull $file_name
    adb shell rm $file_name

    if [ $res != 0 ] ; then
        echo "$(tput setab 1) --- Screenshot Error! ☠ --- $(tput sgr0)"
    else
        echo "$(tput setab 2) --- screenshot $file_name saved to $cur --- $(tput sgr0)"
    fi
    exit $res
}

# ------------------------------------------------------------------------------
gfxbench_test() {
    #adb shell monkey -p net.kishonti.gfxbench.gl.v50000.corporate 1
    echo "$(tput setab 3) install gfxbench.apk $(tput sgr0)"
    hwc-apk.sh i ~/Downloads/03-media/App/gfxbench.apk
    sleep 30

    echo "$(tput setab 3) run gfxbench.apk $(tput sgr0)"
    hwc-apk.sh r ~/Downloads/03-media/App/gfxbench.apk

    sleep 30
    adb shell input tap 1090 580
    sleep 120 # wait for copy 2min

    adb shell input tap 1042 670 # test selection
    adb shell input tap 1500 130 # check 1
    adb shell input roll 0 10
    adb shell input tap 1500 682 # gl_egypt_off
    adb shell input tap 1500 760 # check 2
    adb shell input roll 0 10
    adb shell input roll 0 10
    adb shell input tap 1500 177 # check 3
    adb shell input tap 1500 573 # check 4

    adb shell input tap 1760 82 # start
    sleep 300 # wait result 5min
}

glmark_test() {
    adb shell monkey -p org.linaro.glmark2 1
}

# ------------------------------------------------------------------------------
show_usage() {
    echo "help    )   show_usage        "
    echo "api     )   test_apis         "
    echo "ham     )   test_hameleon     "
    echo "water   )   test_water        "
    echo "cube    )   test_cubes        "
    echo "auto    )   test_auto         "
    echo "loop cmd)   test_loop         "
    echo "monkey  )   test_monkey       "
    echo "                              "
    echo "-1)       back                "
    echo "0 )       home                "
    echo "1 )       maps                "
    echo "2 )       phone               "
    echo "3 )       player              "
    echo "4 )       kitchen             "
    echo "                              "
    echo "bcc )     bccatomictest [crtc]"
    echo "fps )     test_fps [0|1]      "
    echo "scrn )    test_scrn [disp] [coment]"
    echo "                              "
    echo "gfx)      gfxbench_test       "
    echo "glm)      glmark_test         "
}

if [ $# == 0 ]; then
    show_usage
    exit 0
fi

case $1 in
help    )   show_usage      ;;
api     )   test_apis       ;;
ham     )   test_hameleon   ;;
water   )   test_water      ;;
cube    )   test_cubes      ;;
auto    )   test_auto       ;;
loop    )   test_loop ${@:2};;
monkey  )   test_monkey     ;;

-1) adb shell input keyevent BACK;;   # back
0 ) adb shell input tap 1000 1050;;   # home
1 ) adb shell input tap 500 1050;;    # maps
2 ) adb shell input tap 750 1050;;    # phone
3 ) adb shell input tap 1250 1050;;   # player
4 ) adb shell input tap 1500 1050;;   # kitchen

bcc )     test_bccatomic $2 ;;
fps )     test_fps       $2 ;;
scrn )    test_scrn      $2 $3;;

gfx)    gfxbench_test ;;
glm)    glmark_test   ;;

*)  show_usage; exit 1
esac

exit 0
