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
BCC_DBG_BUILD_STR="D=1 PVRSRV_NEED_PVR_ASSERT=1 PVRSRV_NEED_PVR_DPF=1 PVR_SERVICES_DEBUG=1 PVRSRV_ENABLE_PERPID_STATS=1 PVRSRV_ENABLE_CACHEOP_STATS=1 PVRSRV_ENABLE_MEMORY_STATS=1 PVRSRV_ENABLE_GPU_MEMORY_INFO=1 PVRSRV_ENABLE_MEMTRACK_STATS_FILE=1 PVRSRV_DEBUG_LINUX_MEMORY_STATS=1 PVRSRV_ENABLE_PROCESS_STATS=1"
#BCC_DBG_BUILD="D=1 PVR_RI_DEBUG=1 PVRSRV_NEED_PVR_DPF=1 PVRSRV_NEED_PVR_ASSERT=1 PVR_SERVICES_DEBUG=1"
# PVRSRV_NEED_PVR_STACKTRACE=1 PVRSRV_NEED_PVR_STACKTRACE_NATIVE=1 PVRSRV_NEED_PVR_TRACE=1
#if [[ $1 == "d" ]]; then
#fi

# profile
# GCOV_DIR=/sdcard/gcov
# NATIVE_COVERAGE=true
if [[ $1 == "p" ]]; then
    BCC_DBG_BUILD="D=1 GCOV_BUILD=on"
fi

#BCC_DEVICE="DEVICE=M3"
BCC_DEVICE=""
if [[ $workspace == *"m3n" ]]; then
    BCC_DEVICE="DEVICE=M3N"
fi

#-------------------------------------------------------------------------------
ddk_install() {
    adb root && adb remount && adb push ./out/vendor / && adb push ./powervr.ini /vendor/etc/ && adb reboot # echo
    #adb root && adb remount && adb push ./out/vendor / && adb reboot # echo
}

prepare_q_out() {
    pushd $workspace/out/target/product/salvator/system/apex
    ln -s com.android.runtime.debug com.android.runtime
    cd ..
    rm lib64/libc.so lib64/libdl.so lib64/libm.so
    cp apex/com.android.runtime/lib64/bionic/libc.so lib64/libc.so
    cp apex/com.android.runtime/lib64/bionic/libdl.so lib64/libdl.so
    cp apex/com.android.runtime/lib64/bionic/libm.so lib64/libm.so
    rm lib/libc.so lib/libdl.so lib/libm.so
    cp apex/com.android.runtime/lib/bionic/libc.so lib/libc.so
    cp apex/com.android.runtime/lib/bionic/libdl.so lib/libdl.so
    cp apex/com.android.runtime/lib/bionic/libm.so lib/libm.so
    popd

    pushd $workspace/out/target/product/salvator/system/lib64
    ln -s vndk-29 vndk-
    ln -s vndk-sp-29 vndk-sp-
    cd ../lib
    ln -s vndk-29 vndk-
    ln -s vndk-sp-29 vndk-sp-
    popd
}

build_q() {
    BCC_DEVICE=""
    if [[ $1 == "M3" ]]; then
        BCC_DEVICE="DEVICE=M3"
    elif [[ $1 == "M3N" ]]; then
        BCC_DEVICE="DEVICE=M3N"
    fi

    if [[ $1 == "d" ]]; then
        BCC_DBG_BUILD=$BCC_DBG_BUILD_STR
    fi
    
    if [[ $2 == "d" ]]; then
        BCC_DBG_BUILD=$BCC_DBG_BUILD_STR
    fi

    echo "$(tput setab 3) --- Build DDK Q: $BCC_DEVICE $BCC_DBG_BUILD $BCC_EXTRA_FLAGS with: ${@:1} --- $(tput sgr0)"

    pushd $workspace
    source build/envsetup.sh # echo
    lunch $board-userdebug # echo
    popd

    pushd $ddk
    #rm -r out/ .outintum/ .outintkm/
    export TARGET_PLATFORM=android-29
    export PLATFORM_RELEASE=10
    export ANDROID_DDK_DEPS=$ndk

    #export MAKE='compiledb make'
    #make ${BCC_DBG_BUILD} ${@:1}
    make install-um $BCC_DEVICE $BCC_DBG_BUILD $BCC_EXTRA_FLAGS #--trace SHELL='sh -x' SHELL='bash'
    #make $BCC_DEVICE $BCC_DBG_BUILD $BCC_EXTRA_FLAGS #--trace #SHELL='sh -x' SHELL='bash' -j

    popd
}

ddk_copy_q() {

    r8axxx=r8a7795
    if [[ $1 == "M3" ]]; then
        r8axxx=r8a7796
    elif [[ $1 == "M3N" ]]; then
        r8axxx=r8a77965
    fi

    um_dir=$workspace/hardware/renesas/proprietary/gfx/$r8axxx/vendor
    km_dir=$workspace/hardware/renesas/modules/gfx

    # sync KM
    rsync -av --delete --exclude=.git ./rogue_km/ $km_dir/

    # cp firmware
    cp .outintum/target_neutral/rgx.fw.* ./out/vendor/etc/firmware/

    # sync UM
    rsync -av --delete --exclude=.git --exclude=rgx.fw.*.vz ./out/vendor/ $um_dir/
    rsync -av ./out/vendor/ $um_dir/
    cp ./powervr.ini $um_dir/etc/

    # cleanup
    rm $um_dir/bin/hwperfbin2jsont
    rm $um_dir/bin/pvrhwperf
    rm $um_dir/bin/pvrlogdump
    rm $um_dir/bin/pvrlogsplit
    rm -r $um_dir/lib/modules/

    pushd $workspace
    source build/envsetup.sh # echo
    lunch $board-userdebug # echo
    popd

    make update-afs D=1
    
    echo "$(tput setab 2) --- Copy to android tree OK, exit 😊 --- $(tput sgr0)"
    exit 0
}

ddk_clean() {
    pushd $ddk
    rm -r .outintkm/ .outintum/ out/
    
    pushd $workspace
    source build/envsetup.sh # echo
    lunch $board-userdebug # echo
    popd

    export ANDROID_ROOT=$workspace
    export DISCIMAGE=$ddk/out
    make clean
    
    popd
}

build_r() {
    BCC_DEVICE=""
    if [[ $1 == "M3" ]]; then
        BCC_DEVICE="DEVICE=M3"
    elif [[ $1 == "M3N" ]]; then
        BCC_DEVICE="DEVICE=M3N"
    fi

    if [[ $1 == "d" ]]; then
        BCC_DBG_BUILD=$BCC_DBG_BUILD_STR
    fi
    
    if [[ $2 == "d" ]]; then
        BCC_DBG_BUILD=$BCC_DBG_BUILD_STR
    fi

    echo "$(tput setab 3) --- Build DDK R with: ${@:1}: $BCC_DEVICE $BCC_DBG_BUILD $BCC_EXTRA_FLAGS --- $(tput sgr0)"

    pushd $workspace
    source build/envsetup.sh # echo
    lunch $board-userdebug # echo
    popd

    pushd $ddk

    make install-in-aosp $BCC_DEVICE $BCC_DBG_BUILD $BCC_EXTRA_FLAGS # D=1 # V=1 MAX_JOBS=1 #--trace SHELL='sh -x' SHELL='bash'

    res=$?
    if [ $res != 0 ] ; then
        echo "$(tput setab 1) --- Error build all ☠ --- $(tput sgr0)"
        exit $res
    fi

    popd
}

#-------------------------------------------------------------------------------
show_usage() {
    echo "r|q [i|cl|cp] || i|cl|cp      "
    echo "r     )   build R             "
    echo "q     )   build Q             "
    echo "i     )   install             "
    echo "d     )   debug               "
    echo "p     )   profile             "
    echo "cp    )   copy to tree        "
    echo "cl    )   clean               "
}         
          
if [ $# == 0 ]; then
    show_usage
    exit 0
fi        
          
case $1 in
r     )     build_r ${@:2}      ;;
q     )     build_q ${@:2}      ;;
i     )     ddk_install         ;;
cp    )     ddk_copy_q ${@:2}   ;;
cl    )     ddk_clean           ;;

*)  show_usage; exit 1
esac

res=$?
if [ $res != 0 ] ; then
    echo "$(tput setab 1) --- Error build ☠ --- $(tput sgr0)"
    exit $res
fi

case $2 in
i     )     ddk_install         ;;
cp    )     ddk_copy_q ${@:3}   ;;
esac

res=$?
if [ $res != 0 ] ; then
    echo "$(tput setab 1) --- Error install ☠ --- $(tput sgr0)"
    exit $res
else
    echo "$(tput setab 2) --- Finished! Enjoy! 😊 --- $(tput sgr0)"
fi

exit 0
