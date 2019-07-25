#!/bin/bash

BCC_DBG_BUILD="D=1 GCOV_BUILD=on"
#export NATIVE_COVERAGE=true;

source_lunch() {
    echo "$(tput setab 4) --- Prepare enviroment --- $(tput sgr0)"
    echo "$(tput setab 3) --- workspace: $workspace --- $(tput sgr0)"
    echo "$(tput setab 3) --- device: $board $TARGET_BOARD_PLATFORM --- $(tput sgr0)"

    pushd $workspace
    source build/envsetup.sh
    lunch $board-userdebug
    popd
}

hwc_build() {
    source_lunch

    echo "$(tput setab 4) --- building: $1 --- $(tput sgr0)"
    cd $1

    mm -j10
    # showcommands
    #2>&1 | grep -iw error | head -10 #TODO: test mode

    res=$?
    if [ $res != 0 ] ; then
        echo "$(tput setab 1) --- Error build! ☠ --- $(tput sgr0)"
    else
        echo "$(tput setab 2) --- Finished! Enjoy! 😊 --- $(tput sgr0)"
    fi
    exit $res
}

build_noflash() {
    source_lunch

    pushd $workspace

    #echo "$(tput setab 3) --- Clean --- $(tput sgr0)"
    #make installclean

    echo "$(tput setab 3) --- Start building all: ${@:1} --- $(tput sgr0)"
    make -j8 ${@:1}

    #SHELL='sh -x' showcommands VERBOSE=1
    #2>&1 | grep -iw error | head -10 #TODO: test mode

    res=$?
    if [ $res != 0 ] ; then
        echo "$(tput setab 1) --- Error build! ☠ --- $(tput sgr0)"
    else
        echo "$(tput setab 2) --- Finished! Enjoy! 😊 --- $(tput sgr0)"
    fi

    popd # workspace
    exit $res
}

build_flash() {
    source_lunch

    pushd $workspace

    echo "$(tput setab 3) --- Reboot device to fastboot mode --- $(tput sgr0)"
    adb reboot bootloader

    echo "$(tput setab 3) --- Wait device for 30sec --- $(tput sgr0)"
    sleep 30

    echo "$(tput setab 3) --- Fastboot --- $(tput sgr0)"
    if [[ $workspace = *"r-car"* ]]; then
        pushd device/renesas/common
    else
        pushd device/renesas/$board
    fi
    ./fastboot.sh --nobl --noerase --noresetenv
    res=$?

    popd # Fastboot

    if [ $res != 0 ] ; then
        echo "$(tput setab 1) --- Error fastboot! ☠ --- $(tput sgr0)"
    else
        echo "$(tput setab 2) --- Finished! Enjoy! 😊 --- $(tput sgr0)"
    fi

    popd # workspace
    exit $res
}

build_all() {
    source_lunch

    pushd $workspace

    #echo "$(tput setab 3) --- Clean --- $(tput sgr0)"
    make installclean

    echo "$(tput setab 3) --- Start building all: ${@:1} --- $(tput sgr0)"
    make -j10 ${@:1}

    #2>&1 | grep -iw error | head -10 #TODO: test mode

    res=$?
    if [ $res != 0 ] ; then
        echo "$(tput setab 1) --- Error build! ☠ --- $(tput sgr0)"
        popd
        exit $res
    fi

    echo "$(tput setab 3) --- Reboot device to fastboot mode --- $(tput sgr0)"
    adb reboot bootloader

    echo "$(tput setab 3) --- Wait device for 30sec --- $(tput sgr0)"
    sleep 30

    echo "$(tput setab 3) --- Fastboot --- $(tput sgr0)"
    if [[ $workspace = *"r-car"* ]]; then
        pushd device/renesas/common
    else
        pushd device/renesas/$board
    fi
    ./fastboot.sh --nobl --noerase --noresetenv
    res=$?

    popd # Fastboot

    if [ $res != 0 ] ; then
        echo "$(tput setab 1) --- Error fastboot! ☠ --- $(tput sgr0)"
    else
        echo "$(tput setab 2) --- Finished! Enjoy! 😊 --- $(tput sgr0)"
    fi

    popd # workspace
    exit $res
}

build_q() {
    pushd $workspace

    source_lunch

    if [[ $1 == "cl" ]]; then
        make installclean
    fi

    echo "$(tput setab 3) --- Start building Q [$1] --- $(tput sgr0)"
    make -j24

    res=$?
    if [ $res != 0 ] ; then
        echo "$(tput setab 1) --- Error build! ☠ --- $(tput sgr0)"
        popd # workspace
        exit $res
    fi

    if [[ $1 == "bl" ]]; then
        make bootloader.img
    fi
    
    if [[ $1 == "no" ]]; then
        echo "$(tput setab 2) --- Finished! Enjoy! 😊 --- $(tput sgr0)"
        popd # workspace
        exit $res
    fi

    echo "$(tput setab 3) --- Reboot device to fastboot mode --- $(tput sgr0)"
    adb reboot bootloader

    echo "$(tput setab 3) --- Wait device for 30sec --- $(tput sgr0)"
    sleep 30

    if [[ $1 == "bl" ]]; then
        echo "$(tput setab 3) --- Fastboot with bootloader --- $(tput sgr0)"
        vendor/renesas/utils/fastboot/fastboot.sh # --noerase --noresetenv
    elif [[ $1 == "er" ]]; then
        echo "$(tput setab 3) --- Fastboot with erase --- $(tput sgr0)"
        vendor/renesas/utils/fastboot/fastboot.sh --nobl
    else
        echo "$(tput setab 3) --- Fastboot --- $(tput sgr0)"
        vendor/renesas/utils/fastboot/fastboot.sh --noerase --noresetenv --nobl
    fi

    res=$?
    if [ $res != 0 ] ; then
        echo "$(tput setab 1) --- Error fastboot! ☠ --- $(tput sgr0)"
    else
        echo "$(tput setab 2) --- Finished! Enjoy! 😊 --- $(tput sgr0)"
    fi

    popd # workspace
    exit $res
}

build_clean() {
    # make clober
    source_lunch

    pushd $workspace


    if [[ $# == 0 || $1 == "all" ]]; then
        echo "$(tput setab 3) --- Clean ALL --- $(tput sgr0)"
        make installclean
        popd # workspace
        exit 0
    fi

    CLEAN_TARGET=$1
    echo "$(tput setab 3) --- Clean $CLEAN_TARGET --- $(tput sgr0)"
    if [[ $1 == "hwc" ]]; then
        CLEAN_TARGET=android.hardware.graphics.composer@2.4-service.renesas
    fi

    make clean-$CLEAN_TARGET

    popd # workspace
}

# ------------------------------------------------------------------------------
show_usage() {
    echo ".      )   build .        "
    echo "hwc    )   build hwc      "
    echo "all    )   build all [*] +fastboot"
    echo "q      )   build all Q [cl,bl,no]"
    echo "r      )   build all R [cl,bl,no]"
    echo "nofl   )   build all [*]  "
    echo "flash  )   fastboot       "
    echo "cts    )   build cts      "
    echo "gcov   )  build gcov      "
    echo "cl     )   build_clean <module>"
    echo "  cl hwc"
    echo "  cl [all]"
}

if [ $# == 0 ]; then
    show_usage
    exit 0
fi

case $1 in
.       )   hwc_build `pwd`         ;;
hwc     )   hwc_build $hwcomposer   ;;
all     )   build_all ${@:2}        ;;
q       )   build_q ${@:2}          ;;
r       )   build_q ${@:2}          ;;
nofl    )   build_noflash ${@:2}    ;;
flash   )   build_flash             ;;
cts     )   build_noflash cts       ;;
gcov    )   build_all NATIVE_COVERAGE=true           ;;
cl      )   build_clean $2          ;;

*)  show_usage; exit 1
esac

exit 0
