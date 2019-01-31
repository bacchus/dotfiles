#!/bin/bash

BCC_DBG_BUILD="D=1 GCOV_BUILD=on"

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

    #    pushd $workspace
    #    make clean-<package>
    #    popd

    # showcommands

    echo "$(tput setab 4) --- building: $1 --- $(tput sgr0)"
    cd $1
    #export NATIVE_COVERAGE=true;
    mm -j8
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
    make -j8 ${@:1}
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

build_clean() {
    source_lunch

    pushd $workspace

    echo "$(tput setab 3) --- Clean $1 --- $(tput sgr0)"

    if [[ $1 = "all" ]]; then
        make installclean
        popd # workspace
        exit 0
    fi

    CLEAN_TARGET=$1
    if [[ $1 = "hwc" ]]; then
        CLEAN_TARGET=android.hardware.graphics.composer@2.1-service.renesas
    fi

    make clean-$CLEAN_TARGET

    popd # workspace
}

# ------------------------------------------------------------------------------
show_usage() {
    echo ".      )   build .        "
    echo "hwc    )   build hwc      "
    echo "all    )   build all [*] +fastboot"
    echo "nofl   )   build all [*]  "
    echo "flash  )   fastboot       "
    echo "cts    )   build cts      "
    echo "gcov   )  build gcov      "
    echo "clean  )   build_clean <module>"
    echo "  clean hwc"
    echo "  clean all"
}

if [ $# == 0 ]; then
    show_usage
    exit 0
fi

case $1 in
.       )   hwc_build `pwd`         ;;
hwc     )   hwc_build $hwcomposer   ;;
all     )   build_all ${@:2}        ;;
nofl    )   build_noflash ${@:2}    ;;
flash   )   build_flash             ;;
cts     )   build_noflash cts       ;;
gcov    )   build_all NATIVE_COVERAGE=true           ;;
clean   )   build_clean $2          ;;

*)  show_usage; exit 1
esac

exit 0
