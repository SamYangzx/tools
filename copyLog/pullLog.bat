adb root
adb remount


adb pull /storage/sdcard0/mtklog/mobilelog/ ./mobilelog/
adb pull /data/anr/ ./anr/
adb pull /data/tombstone/ .tombstone/

adb shell rm -r /data/anr/
adb shell rm -r /storage/sdcard0/mtklog/mobilelog/
adb shell rm -r /data/tombstone/