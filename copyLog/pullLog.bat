
adb root
adb remount

@echo off
set d=%date:~0,4%-%date:~5,2%-%date:~8,2%
set hour=%time:~,2%
set min_sec=%time:~3,2%-%time:~6,2%
if "%time:~,1%"==" " set hour=0%time:~1,1%
set t=%hour%-%min_sec%
@echo on
set FOLDER=%d%_%t%

mkdir %FOLDER%

adb pull /cache/recovery/ %FOLDER%/
adb pull /data/anr/ %FOLDER%/
adb pull /data/tombstones/ %FOLDER%/
adb pull /sdcard/mtklog/ %FOLDER%/
adb logcat -G 20m
adb logcat > %FOLDER%/logcat.log




