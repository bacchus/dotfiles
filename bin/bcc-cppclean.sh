#!/bin/bash

BCC_PATH=$PWD

echo "--- hello kittie=) ---"
echo "--- check: $BCC_PATH ---"

interfaces=$workspace/out/soong/.intermediates/hardware/interfaces

#--check-config
#

#cppcheck --enable=all $BCC_PATH \
#-DHWC2_USE_CPP11                        \
#-DHWC2_INCLUDE_STRINGIFICATION          \


cppclean $BCC_PATH \
-I $kernel/drivers/android                                                      \
-I $kernel/drivers/clk                                                          \
-I $kernel/drivers/dma-buf                                                      \
-I $kernel/drivers/gpu/drm                                                      \
-I $kernel/drivers/gpu/drm/bridge                                               \
-I $kernel/drivers/gpu/drm/rcar-du                                              \
-I $kernel/drivers/media/platform                                               \
-I $kernel/drivers/media/platform/vsp1                                          \
-I $kernel/drivers/staging/android/ion                                          \
-I $kernel/include                                                              \
-I $kernel/include/drm                                                          \
-I $kernel/include/drm/bridge                                                   \
-I $kernel/include/media                                                        \
-I $kernel/include/uapi/drm                                                     \
-I $kernel/include/uapi/linux/android                                           \
-I $workspace/external/libdrm                                                   \
-I $workspace/frameworks/native/include                                         \
-I $workspace/frameworks/native/opengl/include                                  \
-I $workspace/frameworks/native/include/gui                                     \
-I $workspace/frameworks/native/libs/gui/include                                \
-I $workspace/frameworks/native/libs/ui/include                                 \
-I $workspace/frameworks/native/services/surfaceflinger                         \
-I $workspace/frameworks/native/services/surfaceflinger/DisplayHardware         \
-I $workspace/hardware/interfaces/graphics/composer/2.1/default                 \
-I $workspace/hardware/libhardware/include                                      \
-I $workspace/hardware/renesas/hwcomposer                                       \
-I $workspace/system/core/include                                               \
-I $workspace/system/core/libsync                                               \
-I $workspace/out/soong/.intermediates/vendor/renesas/hardware/interfaces/graphics/composer/1.0/vendor.renesas.graphics.composer@1.0_genc++_headers/gen \
-I $interfaces/vr/1.0/android.hardware.vr@1.0_genc++_headers/gen \
-I $interfaces/audio/2.0/android.hardware.audio@2.0_genc++_headers/gen \
-I $interfaces/audio/effect/2.0/android.hardware.audio.effect@2.0_genc++_headers/gen \
-I $interfaces/audio/common/2.0/android.hardware.audio.common@2.0_genc++_headers/gen \
-I $interfaces/automotive/vehicle/2.0/android.hardware.automotive.vehicle@2.0_genc++_headers/gen \
-I $interfaces/automotive/evs/1.0/android.hardware.automotive.evs@1.0_genc++_headers/gen \
-I $interfaces/neuralnetworks/1.0/android.hardware.neuralnetworks@1.0_genc++_headers/gen \
-I $interfaces/broadcastradio/1.1/android.hardware.broadcastradio@1.1_genc++_headers/gen \
-I $interfaces/broadcastradio/1.0/android.hardware.broadcastradio@1.0_genc++_headers/gen \
-I $interfaces/power/1.1/android.hardware.power@1.1_genc++_headers/gen \
-I $interfaces/power/1.0/android.hardware.power@1.0_genc++_headers/gen \
-I $interfaces/drm/1.0/android.hardware.drm@1.0_genc++_headers/gen \
-I $interfaces/boot/1.0/android.hardware.boot@1.0_genc++_headers/gen \
-I $interfaces/tv/cec/1.0/android.hardware.tv.cec@1.0_genc++_headers/gen \
-I $interfaces/tv/input/1.0/android.hardware.tv.input@1.0_genc++_headers/gen \
-I $interfaces/health/1.0/android.hardware.health@1.0_genc++_headers/gen \
-I $interfaces/memtrack/1.0/android.hardware.memtrack@1.0_genc++_headers/gen \
-I $interfaces/configstore/1.0/android.hardware.configstore@1.0_genc++_headers/gen \
-I $interfaces/graphics/mapper/2.0/android.hardware.graphics.mapper@2.0_genc++_headers/gen \
-I $interfaces/graphics/allocator/2.0/android.hardware.graphics.allocator@2.0_genc++_headers/gen \
-I $interfaces/graphics/bufferqueue/1.0/android.hardware.graphics.bufferqueue@1.0_genc++_headers/gen \
-I $interfaces/graphics/common/1.0/android.hardware.graphics.common@1.0_genc++_headers/gen \
-I $interfaces/graphics/composer/2.1/android.hardware.graphics.composer@2.1_genc++_headers/gen \
-I $interfaces/ir/1.0/android.hardware.ir@1.0_genc++_headers/gen \
-I $interfaces/thermal/1.1/android.hardware.thermal@1.1_genc++_headers/gen \
-I $interfaces/thermal/1.0/android.hardware.thermal@1.0_genc++_headers/gen \
-I $interfaces/camera/device/1.0/android.hardware.camera.device@1.0_genc++_headers/gen \
-I $interfaces/camera/device/3.3/android.hardware.camera.device@3.3_genc++_headers/gen \
-I $interfaces/camera/device/3.2/android.hardware.camera.device@3.2_genc++_headers/gen \
-I $interfaces/camera/provider/2.4/android.hardware.camera.provider@2.4_genc++_headers/gen \
-I $interfaces/camera/metadata/3.2/android.hardware.camera.metadata@3.2_genc++_headers/gen \
-I $interfaces/camera/common/1.0/android.hardware.camera.common@1.0_genc++_headers/gen \
-I $interfaces/gatekeeper/1.0/android.hardware.gatekeeper@1.0_genc++_headers/gen \
-I $interfaces/bluetooth/1.0/android.hardware.bluetooth@1.0_genc++_headers/gen \
-I $interfaces/biometrics/fingerprint/2.1/android.hardware.biometrics.fingerprint@2.1_genc++_headers/gen \
-I $interfaces/radio/1.1/android.hardware.radio@1.1_genc++_headers/gen \
-I $interfaces/radio/deprecated/1.0/android.hardware.radio.deprecated@1.0_genc++_headers/gen \
-I $interfaces/radio/1.0/android.hardware.radio@1.0_genc++_headers/gen \
-I $interfaces/renderscript/1.0/android.hardware.renderscript@1.0_genc++_headers/gen \
-I $interfaces/tetheroffload/config/1.0/android.hardware.tetheroffload.config@1.0_genc++_headers/gen \
-I $interfaces/tetheroffload/control/1.0/android.hardware.tetheroffload.control@1.0_genc++_headers/gen \
-I $interfaces/soundtrigger/2.0/android.hardware.soundtrigger@2.0_genc++_headers/gen \
-I $interfaces/nfc/1.0/android.hardware.nfc@1.0_genc++_headers/gen \
-I $interfaces/weaver/1.0/android.hardware.weaver@1.0_genc++_headers/gen \
-I $interfaces/vibrator/1.1/android.hardware.vibrator@1.1_genc++_headers/gen \
-I $interfaces/vibrator/1.0/android.hardware.vibrator@1.0_genc++_headers/gen \
-I $interfaces/cas/native/1.0/android.hardware.cas.native@1.0_genc++_headers/gen \
-I $interfaces/cas/1.0/android.hardware.cas@1.0_genc++_headers/gen \
-I $interfaces/media/1.0/android.hardware.media@1.0_genc++_headers/gen \
-I $interfaces/media/omx/1.0/android.hardware.media.omx@1.0_genc++_headers/gen \
-I $interfaces/wifi/1.1/android.hardware.wifi@1.1_genc++_headers/gen \
-I $interfaces/wifi/supplicant/1.0/android.hardware.wifi.supplicant@1.0_genc++_headers/gen \
-I $interfaces/wifi/1.0/android.hardware.wifi@1.0_genc++_headers/gen \
-I $interfaces/wifi/offload/1.0/android.hardware.wifi.offload@1.0_genc++_headers/gen \
-I $interfaces/keymaster/3.0/android.hardware.keymaster@3.0_genc++_headers/gen \
-I $interfaces/sensors/1.0/android.hardware.sensors@1.0_genc++_headers/gen \
-I $interfaces/usb/1.1/android.hardware.usb@1.1_genc++_headers/gen \
-I $interfaces/usb/1.0/android.hardware.usb@1.0_genc++_headers/gen \
-I $interfaces/light/2.0/android.hardware.light@2.0_genc++_headers/gen \
-I $interfaces/dumpstate/1.0/android.hardware.dumpstate@1.0_genc++_headers/gen \
-I $interfaces/oemlock/1.0/android.hardware.oemlock@1.0_genc++_headers/gen \
-I $interfaces/contexthub/1.0/android.hardware.contexthub@1.0_genc++_headers/gen \
-I $interfaces/gnss/1.0/android.hardware.gnss@1.0_genc++_headers/gen    \



#-I $workspace/system/libhidl/base/include \
#-I $workspace/bionic/libc/include \
#-I $workspace/bionic/libc/kernel/uapi \
#-I $workspace/bionic/libc/kernel/uapi/linux \
#-I $workspace/bionic/libc/kernel/uapi/asm-arm64 \
#-I $workspace/out/soong/.intermediates/system/libhidl/transport/manager/1.0/android.hidl.manager@1.0_genc++_headers/gen \
#-I $workspace/out/soong/.intermediates/system/libhidl/transport/base/1.0/android.hidl.base@1.0_genc++_headers/gen \
#-I $workspace/system/libfmq/include \
#-I $workspace/system/core/libsync/include \
#-I $workspace/external/libcxx/include \
#-I $workspace/device/renesas/kernel/arch/ia64/include \
#-I $workspace/device/renesas/kernel/arch/ia64/include/uapi \
#-I $workspace/device/renesas/kernel/arch/arm64/include \
#-I $workspace/external/clang/lib/Headers \
#-I $workspace/prebuilts/clang/host/linux-x86/clang-4691093/include/clang/AST \
#-I $workspace/prebuilts/clang/host/linux-x86/clang-4691093/include \
#-I $workspace/out/target/product/salvator/obj/KERNEL_OBJ/include \
#-I $workspace/system/libhidl/transport/include

