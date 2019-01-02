#!/bin/bash

BCC_DBG_BUILD=""
# non-debug
if [[ $1 == "n" ]]; then
    BCC_DBG_BUILD=""
fi

# debug
if [[ $1 == "d" ]]; then
    BCC_DBG_BUILD="D=1 PVR_RI_DEBUG=1 PVRSRV_NEED_PVR_DPF=1 PVRSRV_NEED_PVR_ASSERT=1"
fi

# profile
# GCOV_DIR=/sdcard/gcov
# NATIVE_COVERAGE=true
if [[ $1 == "p" ]]; then
    BCC_DBG_BUILD="D=1 GCOV_BUILD=on"
fi

#BCC_DEVICE="DEVICE=M3"
BCC_DEVICE=""
if [[ $workspace = *"m3n" ]]; then
    BCC_DEVICE="DEVICE=M3N"
fi

#-------------------------------------------------------------------------------
show_usage() {
    echo "i     )   install             "
    echo "d     )   debug               "
    echo "n     )   non-debug           "
    echo "p     )   profile             "
    echo "d i   )   debug install       "
}

if [ $# == 0 ]; then
    show_usage
    exit 0
fi

#-------------------------------------------------------------------------------
echo "$(tput setab 3) --- Build ddk: $BCC_DEVICE $BCC_DBG_BUILD --- $(tput sgr0)"
pushd $ddk

if [[ $1 == "i" ]]; then
    adb root && adb remount && adb push ./out/vendor / && adb reboot # echo
    echo "$(tput setab 2) --- Install OK, exit 😊 --- $(tput sgr0)"
    exit 0
fi

if [[ $1 == "cp2m3n" ]]; then
    rsync -av \
    ./out/vendor/ \
    $proprietary/imgtec/prebuilts/r8a77965/vendor/
    echo "$(tput setab 2) --- Copy to m3n tree OK, exit 😊 --- $(tput sgr0)"
    exit 0
fi

pushd $workspace
source build/envsetup.sh # echo
lunch $board-userdebug # echo
popd

rm -r .outintkm/ .outintum/ out/ # echo
make $BCC_DEVICE $BCC_DBG_BUILD # SHELL='sh -x' # echo

#-------------------------------------------------------------------------------
res=$?
if [ $res != 0 ] ; then
    echo "$(tput setab 1) --- Error build ☠ --- $(tput sgr0)"
    popd
    exit $res
else
    echo "$(tput setab 2) --- OK 😊 --- $(tput sgr0)"
fi

#-------------------------------------------------------------------------------
if [[ $2 == "i" ]]; then
    adb root && adb remount && adb push ./out/vendor / && adb reboot # echo
fi

#-------------------------------------------------------------------------------
popd
echo "$(tput setab 2) --- Finished! Enjoy! 😊 --- $(tput sgr0)"
exit 0
