::请先设置sdk build-tools路径
set BUILD_TOOL="D:\sdk\android-sdk-windows\build-tools\30.0.2\apksigner.bat"

@echo off
::指定起始文件夹， "%cd%"当前文件夹；%DIR%设置一个变量；%TAR_DIR%表示手机下的目的路径
set DIR="%cd%"
echo DIR=%DIR%

:: 参数 /R 表示需要遍历子文件夹,去掉表示不遍历子文件夹
:: %%f 是一个变量,类似于迭代器,但是这个变量只能由一个字母组成,前面带上%%
:: 括号中是通配符,可以指定后缀名,*.*表示所有文件
::  签名后的apk会覆盖签名前的apk
 
for /R %DIR% %%f in (*.apk) do ( 
    echo %%f
   %BUILD_TOOL%  sign --key platform.pk8 --cert platform.x509.pem %%f  
   @pause
)

@pause


