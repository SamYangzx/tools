@echo on
adb remount
adb shell mount -o rw,remount /system
adb shell mount -o rw,remount /vendor


adb push Y:\FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng\out\target\product\aiv8167sm3_bsp\system\framework\oat /system/framework
adb push Y:\FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng\out\target\product\aiv8167sm3_bsp\system\framework\arm /system/framework
adb push Y:\FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng\out\target\product\aiv8167sm3_bsp\system\framework\framework.jar /system/framework
adb push Y:\FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng\out\target\product\aiv8167sm3_bsp\system\framework\android.hardware.wifi-V1.1-java.jar /system/framework
adb push Y:\FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng\out\target\product\aiv8167sm3_bsp\system\framework\CustomPropInterface.jar /system/framework

adb push Y:\FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng\out\target\product\aiv8167sm3_bsp\system\framework\services.jar /system/framework
adb push Y:\FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng\out\target\product\aiv8167sm3_bsp\system\framework\services.jar.prof /system/framework

adb push Y:\FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng\out\target\product\aiv8167sm3_bsp\system\framework\wifi-service.jar /system/framework
adb push Y:\FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng\out\target\product\aiv8167sm3_bsp\system\framework\wifi-service.jar.prof /system/framework

adb push Y:\FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng\out\target\product\aiv8167sm3_bsp\vendor\bin\hw\android.hardware.wifi@1.0-service /vendor/bin/hw
adb push Y:\FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng\out\target\product\aiv8167sm3_bsp\system\bin\wificond /system/bin

::adb push ~/FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng/out/target/product/aiv8167sm3_bsp/obj/ETC/wlan_drv_gen4_mt7668.ko_intermediates/wlan_drv_gen4_mt7668.ko /vendor/lib/modules


:: adb push Y:\FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng\out\target\product\aiv8167sm3_bsp\system\framework\framework-res.apk /system/framework
:: adb push Y:\FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng\out\target\product\aiv8167sm3_bsp\system\framework\mediatek-res /system/framework/mediatek-res
:: adb push Y:\FiberHome-aiv8167sm3_bsp-AIR1201-D01_IOT-NONSECURITY-eng\out\target\product\aiv8167sm3_bsp\system\framework\mediatek-services.jar /system/framework

adb reboot

@pause