#!/bin/bash

debug_root() {
    adb root
    if [ $? != 0 ] ; then
        echo "$(tput setab 1) --- Error in adb root! ☠ --- $(tput sgr0)"
        exit $res
    fi
}

debug_all() {
    debug_root
    adb shell 'echo 1 > /sys/module/vsp1/parameters/debug'

    tput clear;
    while sleep 1;
    do
        tput sc; tput cup 0 0;

        #### 2: ion buffers
        echo "ions (15-ok)  : `adb shell 'cat /d/ion/heaps/rcar\ custom' | wc -l`";

        #### 4: lsof composer
        echo "hwcf (100-ok) : `adb shell lsof | grep composer | wc -l`";

        #### 4: lsof evs
        echo "evsf (100-ok) : `adb shell lsof | grep evs | wc -l`";

        #### 5: underrun
        echo "urun (0-ok)   : `adb shell 'cat /sys/module/vsp1/parameters/underrun_vspd'`"

        # echo "================================================================================================="

        #### 1: DRM_DEBUG from drivers/gpu/drm
        # adb shell 'cat /proc/kmsg' >> ~/logs/drm_drv_dbg.txt;

        #### 3: SurfaceFlinger dump
        # adb shell dumpsys SurfaceFlinger;

        tput rc;

    done
}

debug_lsof() {
    debug_root

    while sleep 1;
    do
        tput clear; tput sc; tput cup 0 0;

        adb shell 'cat /proc/sys/fs/file-nr'
        adb shell lsof | grep "$1" | wc -l

        tput rc;
    done
}

debug_ion() {
    debug_root

    while sleep 1;
    do
        tput clear; tput sc; tput cup 0 0;

        adb shell 'cat /proc/meminfo | grep CmaFree'

        #adb shell 'cat /d/ion/heaps/ion_heap'

        #        if [[ $workspace = *"r-car" ]]; then
        #            adb shell 'cat /d/ion/heaps/rcar\ custom'
        #        else
        #            adb shell 'cat /d/ion/heaps/ion_heap'
        #        fi

        tput rc;
    done
}

debug_gpu() {
    debug_root

    while sleep 1;
    do
        tput clear; tput sc; tput cup 0 0;

        adb shell 'cat /d/pvr/status'

        tput rc;
    done
}

debug_dump() {
    debug_root
    adb shell dumpsys SurfaceFlinger
}

debug_drm() {
    debug_root
    adb shell 'echo 0x1f >/sys/module/drm/parameters/debug'
    echo "=== start ===" > ~/logs/hwc-drm.txt
    while sleep 1;
    do
        adb shell 'cat /proc/kmsg' | tee -a ~/logs/hwc-drm.txt
        #adb shell dmesg | tee -a ~/logs/hwc-drm.txt
    done
}

debug_loop() {
    echo "$(tput setab 4) --- lunch LOOP ${@:1} --- $(tput sgr0)"

    watch -n 0.5 ${@:1};

#    while sleep 1;
#    do
#        tput clear; tput sc; tput cup 0 0;

#        ${@:1};

#        tput rc;
#    done
}

debug_layers() {
    #adb shell dumpsys SurfaceFlinger | awk '/Allocated buffers/,/IMG Graphics HAL state/'
    adb shell dumpsys SurfaceFlinger | awk '/Tracing state/,/IMG Graphics HAL state/'
#    adb shell dumpsys SurfaceFlinger | awk '/Tracing state/,/h\/w composer state/'
}

# ------------------------------------------------------------------------------
log_file=~/logs/psa.txt
filtr_file=~/logs/filtr.txt
tmp_file=~/logs/tmp.txt

show_prcs_num() {
    cur_prcs=$1
    cat $log_file | grep $cur_prcs > $filtr_file
    cur_prcs_num=`cat $filtr_file | wc -l`
    echo "$cur_prcs: $cur_prcs_num typical: $2"
    cat $log_file | grep -v $cur_prcs > $tmp_file
    cat $tmp_file > $log_file
    rm $tmp_file $filtr_file
}

debug_proc() {
    debug_root
    adb shell ps -A > $log_file

    #USER           PID  PPID     VSZ    RSS WCHAN            ADDR S NAME
    #root             2     0       0      0 kthreadd            0 S [kthreadd]

    ## bt WCHAN
    show_prcs_num '             irq_thread' 83
    show_prcs_num '              smpboot_t' 24
    show_prcs_num '          worker_thread' 29
    show_prcs_num '        pvr_fence_sync_' 'ok: 0; crash: 12'
    show_prcs_num '     binder_thread_read' 38
    show_prcs_num '         rescuer_thread' 40
    show_prcs_num '         SyS_epoll_wait' 27
    show_prcs_num '         rcu_gp_kthread' 3
    show_prcs_num '       mmc_queue_thread' 4
    show_prcs_num '  poll_schedule_timeout' 4
    show_prcs_num '   LinuxEventObjectWait' 3
    show_prcs_num '             kjournald2' 3

    echo "other:"
    cat $log_file
}

# ------------------------------------------------------------------------------
show_usage() {
    echo "help    )   show_usage        "
    echo "all     )   debug_all         "
    echo "ion     )   debug_ion         "
    echo "dump    )   debug_dump        "
    echo "drm     )   debug_drm         "
    echo "lsof    )   debug_lsof        "
    echo "loop cmd)   debug_loop        "
    echo "layers  )   debug_layers      "
}

if [ $# == 0 ]; then
    show_usage
    exit 0
fi

case $1 in
help    )   show_usage      ;;
all     )   debug_all       ;;
ion     )   debug_ion       ;;
dump    )   debug_dump      ;;
drm     )   debug_drm       ;;
gpu     )   debug_gpu       ;;
lsof    )   debug_lsof $2   ;;
loop    )   debug_loop ${@:2} ;;
layers  )   debug_layers    ;;
proc    )   debug_proc      ;;
*)  show_usage; exit 1
esac

exit 0
