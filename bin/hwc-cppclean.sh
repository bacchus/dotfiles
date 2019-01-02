#!/bin/bash

#cppcheck
#--check-config
#--enable=all

hwc_inc=                                                                        \
-I $hwcomposer                                                                  \
-I $workspace/hardware/libhardware/include                                      \
-I $workspace/hardware/interfaces/graphics/composer/2.1/default                 \
-I $hwcomposer                                                                  \
-I $workspace/external/libdrm                                                   \
-I $workspace/frameworks/native/services/surfaceflinger                         \
-I $workspace/frameworks/native/services/surfaceflinger/DisplayHardware         \
-I $workspace/frameworks/native/libs/gui                                        \
-I $workspace/frameworks/native/include/gui                                     \
-I $workspace/frameworks/native/libs/ui/include                                 \
-I $workspace/system/core/libsync                                               \
-I $kernel/drivers/staging/android/ion                                          \
-I $kernel/drivers/android                                                      \
-I $kernel/drivers/dma-buf                                                      \
-I $kernel/drivers/gpu/drm                                                      \
-I $kernel/drivers/gpu/drm/rcar-du                                              \
-I $kernel/drivers/gpu/drm/bridge                                               \
-I $kernel/drivers/clk                                                          \
-I $kernel/drivers/media/platform/vsp1                                          \
-I $kernel/drivers/media/platform                                               \
-I $kernel/include/drm                                                          \
-I $kernel/include/drm/bridge                                                   \
-I $kernel/include/media                                                        \
-I $kernel/include/uapi/drm                                                     \
-I $kernel/include/uapi/linux/android                                           \
-I $workspace/out/soong/.intermediates/hardware/interfaces/graphics/composer/2.1/android.hardware.graphics.composer@2.1_genc++_headers/gen


echo "$(tput setab 4) --- checking: $hwcomposer --- $(tput sgr0)"
echo ""

echo "$(tput setab 3) --- check-config --- $(tput sgr0)"
cppcheck $hwcomposer --check-config

echo "$(tput setab 3) --- cppcheck-all --- $(tput sgr0)"
cppcheck $hwcomposer --enable=all

echo "$(tput setab 3) --- cppclean --- $(tput sgr0)"
cppclean $hwcomposer

res=$?
if [ $res != 0 ] ; then
    echo "$(tput setab 1) --- Error happens ☠ --- $(tput sgr0)"
else
    echo "$(tput setab 2) --- Finished! Enjoy! 😊 --- $(tput sgr0)"
fi
exit $res
