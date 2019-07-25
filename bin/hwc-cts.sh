#!/bin/bash

BCC_TOOL=tools/cts-tradefed
#BCC_TOOL=cts-tradefed
# cts-tradefed
# tools/cts-tradefed
# $workspace/out/host/linux-x86/cts/android-cts
# ------------------------------------------------------------------------------
run_test_all() {
    $BCC_TOOL run cts-dev \
    -m $1 \
    -a arm64-v8a \
    -l VERBOSE \
    --logcat-on-failure \
    --skip-device-info \
    --skip-preconditions \
    --skip-system-status-check com.android.compatibility.common.tradefed.targetprep.NetworkConnectivityChecker
}

run_test_1() {
    $BCC_TOOL run cts-dev \
    -m $1 \
    -t $2 \
    -a arm64-v8a \
    -l VERBOSE \
    --logcat-on-failure \
    --skip-device-info \
    --skip-preconditions \
    --skip-system-status-check com.android.compatibility.common.tradefed.targetprep.NetworkConnectivityChecker
}

run_test() {
    pushd $workspace; source build/envsetup.sh; lunch $board-userdebug; popd
    export ANDROID_BUILD_TOP=

    echo "Run cts, TOOL: $BCC_TOOL"
    case $# in
    1 ) run_test_all $1     ;;
    2 ) run_test_1 $1 $2    ;;
    esac
}
# ------------------------------------------------------------------------------
show_usage() {
    echo "$workspace/out/host/linux-x86/cts/android-cts"
    echo "deqp [<test>] )   CtsDeqpTestCases   "
    echo "              dEQP-EGL.functional.get_frame_timestamps#rgb565_depth_stencil"
    echo "              dEQP-EGL.functional.robustness.reset_context.shaders.infinite_loop.query_status#compute"
    echo "              dEQP-GLES31.functional.primitive_bounding_box.points.global_state.vertex_tessellation_geometry_fragment#default_framebuffer_bbox_equal"
    echo "              dEQP-GLES31.functional.shaders.linkage.tessellation_geometry.uniform.rules#struct_partial_usage"
    echo "              dEQP-GLES31.functional.shaders.linkage.tessellation_geometry.varying.types#float"
    echo "              "
    echo "view [<test>] )   CtsViewTestCases   "
    echo "              android.view.cts.SurfaceViewSyncTest#testEmptySurfaceView"
    echo "              "
    echo "rs [<test>] )   CtsRenderscriptTestCases   "
    echo "              android.renderscript.cts.IntrinsicHistogram#test_dot_1"
    echo "              android.renderscript.cts.Float16ArithmeticTest#testFloat16Add"
    echo "              "
    echo "rscpp [<test>] )   CtsRsCppTestCases   "
    echo "              "
    echo "ui [<test>] )   CtsUiHostTestCases   "
    echo "              android.ui.cts.TaskSwitchingTest#testTaskSwitching"
    echo "              "
    echo "nhw [<test>] )   CtsNativeHardwareTestCases   "
    echo "              "
    echo "gra [<test>] )   CtsGraphicsTestCases   "
    echo "              "
}

if [ $# == 0 ]; then
    show_usage
    exit 0
fi

case $1 in
help    )   show_usage; exit 1 ;;
deqp    )   run_test CtsDeqpTestCases $2    ;;
view    )   run_test CtsViewTestCases $2    ;;
rs      )   run_test CtsRenderscriptTestCases $2    ;;
rscpp   )   run_test CtsRsCppTestCases $2   ;;
ui      )   run_test CtsUiHostTestCases $2   ;;
nhw     )   run_test CtsNativeHardwareTestCases $2   ;;
gra     )   run_test CtsGraphicsTestCases $2   ;;
*)          run_test $1 $2   ;;

esac

exit 0
