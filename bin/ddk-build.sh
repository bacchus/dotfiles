#!/bin/bash

#BCC_EXTRA_FLAGS="PVRSRV_SYNC_SEPARATE_TIMELINES=1"
#BCC_EXTRA_FLAGS="GLES2_EXTENSION_KHR_DEBUG=1"
#BCC_EXTRA_FLAGS="API_LEVEL=28 VERBOSE=1 SHELL=/bin/bash"

BCC_DBG_BUILD=""
# non-debug
if [[ $1 == "n" ]]; then
    BCC_DBG_BUILD=""
fi

# debug
if [[ $1 == "d" ]]; then
    BCC_DBG_BUILD="D=1 PVR_RI_DEBUG=1 PVRSRV_NEED_PVR_DPF=1 PVRSRV_NEED_PVR_ASSERT=1 PVR_SERVICES_DEBUG=1"
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
    echo "cp    )   copy to tree        "
    echo "cl    )   clean               "
}

if [ $# == 0 ]; then
    show_usage
    exit 0
fi

#-------------------------------------------------------------------------------
ddk_install() {
    adb root && adb remount && adb push ./out/vendor / && adb push ./powervr.ini /vendor/etc/ && adb reboot # echo
    #adb root && adb remount && adb push ./out/vendor / && adb reboot # echo
}

ddk_copy() {

    rsync -av ./rogue_km/ $proprietary/rogue_km/ --delete

    r8axxx=r8a7795

    cp .outintum/target_neutral/rgx.fw.4.46.6.62 ./out/vendor/etc/firmware/
    rsync -av ./out/vendor/ $proprietary/prebuilts/$r8axxx/vendor/
    cp ./powervr.ini $proprietary/prebuilts/$r8axxx/vendor/etc/

#    rm $proprietary/prebuilts/$r8axxx/vendor/bin/hwperfbin2jsont
#    rm $proprietary/prebuilts/$r8axxx/vendor/bin/pvrhwperf
#    rm $proprietary/prebuilts/$r8axxx/vendor/bin/pvrlogdump
#    rm $proprietary/prebuilts/$r8axxx/vendor/bin/pvrlogsplit
#    rm -r $proprietary/prebuilts/$r8axxx/vendor/lib/modules/

}

ddk_copy_q() {

    r8axxx=r8a7795
    um_dir=$workspace/hardware/renesas/proprietary/gfx/$r8axxx/vendor
    km_dir=$workspace/hardware/renesas/modules/gfx

    # sync KM
    rsync -av --delete --exclude=.git ./rogue_km/ $km_dir/

    # cp firmware
    cp .outintum/target_neutral/rgx.fw.* ./out/vendor/etc/firmware/

    # sync UM
    rsync -av --delete --exclude=.git --exclude=rgx.fw.*.vz ./out/vendor/ $um_dir/
    #rsync -av ./out/vendor/ $um_dir/
    cp ./powervr.ini $um_dir/etc/

    # cleanup
    rm $um_dir/bin/hwperfbin2jsont
    #rm $um_dir/bin/pvrhwperf
    #rm $um_dir/bin/pvrlogdump
    #rm $um_dir/bin/pvrlogsplit
    rm -r $um_dir/lib/modules/
}


#-------------------------------------------------------------------------------
echo "$(tput setab 3) --- Build ddk: $BCC_DEVICE $BCC_DBG_BUILD $BCC_EXTRA_FLAGS --- $(tput sgr0)"
pushd $ddk

if [[ $1 == "i" ]]; then
    ddk_install || echo "$(tput setab 1) --- TEST ☠ --- $(tput sgr0)"
    echo "$(tput setab 2) --- Install OK, exit 😊 --- $(tput sgr0)"
    exit 0
elif [[ $1 == "cp" ]]; then
    ddk_copy || echo "$(tput setab 1) --- TEST ☠ --- $(tput sgr0)"
    echo "$(tput setab 2) --- Copy to android tree OK, exit 😊 --- $(tput sgr0)"
    exit 0
elif [[ $1 == "qcp" ]]; then
    ddk_copy_q || echo "$(tput setab 1) --- TEST ☠ --- $(tput sgr0)"
    echo "$(tput setab 2) --- Copy to QQ android tree OK, exit 😊 --- $(tput sgr0)"
    exit 0
elif [[ $1 == "cl" ]]; then
    rm -r .outintkm/ .outintum/ out/
    echo "$(tput setab 2) --- Clean OK, exit 😊 --- $(tput sgr0)"
    exit 0
fi

pushd $workspace
source build/envsetup.sh # echo
lunch $board-userdebug # echo
popd

#rm -r .outintkm/ .outintum/ out/ # echo
make $BCC_DEVICE $BCC_DBG_BUILD $BCC_EXTRA_FLAGS #--trace #SHELL='sh -x'

# echo
# -j4

#-------------------------------------------------------------------------------
res=$?
if [ $res != 0 ] ; then
    echo "$(tput setab 1) --- Error build ☠ --- $(tput sgr0)"
    popd
    exit $res
else
    echo "$(tput setab 2) --- build OK 😊 --- $(tput sgr0)"
fi

#-------------------------------------------------------------------------------
if [[ $2 == "i" ]]; then
    ddk_install
elif [[ $2 == "cp" ]]; then
    ddk_copy
elif [[ $2 == "qcp" ]]; then
    ddk_copy_q
fi

#-------------------------------------------------------------------------------
popd
echo "$(tput setab 2) --- Finished! Enjoy! 😊 --- $(tput sgr0)"
exit 0
