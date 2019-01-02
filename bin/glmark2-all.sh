#!/bin/bash

cd $workspace

source build/envsetup.sh
lunch $board-userdebug

pushd external/glmark2/android
[[ "$?" = 0 ]] && mm -j8
popd

[[ "$?" = 0 ]] && mkdir -p out/target/product/$board/system/app/GLMark2/lib/arm64
[[ "$?" = 0 ]] && cp out/target/product/$board/system/lib64/libglmark2-android.so out/target/product/$board/system/app/GLMark2/lib/arm64/

cp -r out/target/product/$board/system/app/GLMark2 ~/Downloads/

# install
[[ "$?" = 0 ]] && timeout 20 adb root
[[ "$?" = 0 ]] && timeout 20 adb remount
[[ "$?" = 0 ]] && timeout 20 adb push out/target/product/$board/system/app/GLMark2 /system/app/
[[ "$?" = 0 ]] && timeout 20 adb reboot
sleep 30s # f_wait_for_device "$dev_id"
[[ "$?" = 0 ]] && timeout 30 adb shell am start -a android.intent.action.MAIN -n org.linaro.glmark2/org.linaro.glmark2.Glmark2Activity
