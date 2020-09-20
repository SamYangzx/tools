@echo off

adb root
adb remount
adb shell mount -o rw,remount /system
adb shell mount -o rw,remount /vendor

::@echo off
::指定起始文件夹， "%cd%"当前文件夹；%DIR%设置一个变量
set DIR="%cd%"
echo DIR=%DIR%
set TAR_DIR="/system/app/tengxunhuiyi/lib/arm"
echo TAR_DIR="%TAR_DIR%"

:: 参数 /R 表示需要遍历子文件夹,去掉表示不遍历子文件夹
:: %%f 是一个变量,类似于迭代器,但是这个变量只能由一个字母组成,前面带上%%
:: 括号中是通配符,可以指定后缀名,*.*表示所有文件

for /R %DIR% %%f in (*.so) do ( 
    echo %%f
   adb push %%f %TAR_DIR%
)

@pause