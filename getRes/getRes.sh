#!/bin/bash

########脚本原理 
##将编译生成的log存储于build.log文件中，根据缺损的资源报错特征，去原来的源码路径抓取相关的资源并拷贝至 ${TARGET} 目录中
##举例:比如想从~/src/build/gm_7.0_mtk6750_u1/packages/apps/Settings 移植部分代码到当前目录，在移植了部分文件到本地工程后。编译，可能会报很多资源找不到的错误。
##可以将本脚本拷贝至当前目录后，即可运行本脚本将资源文件抓取处来,避免手动一个个查找。
##
##使用说明：
##1.目前不支持theme,style的移植。
##2.使用前请先修改SRC值，其他参数根据实际需要进行调整
##3.抓取的文件会提取到${TARGET}目录中，根据实际情况合入对应位置
##

LOCAL_PATH=`pwd`
BUILD_LOG=$LOCAL_PATH/build.log     ###编译过后保存的log文件，必须和 mm -B -j8 2>&1 | tee build.log 此命令生成的文件一致####
SEARCH_TAR="error: resource "       ###匹配原则###
TEMP_SEARCH_TAR_FILE=$LOCAL_PATH/search.log     ###生成的临时文件###
SRC=~/src/build/gm_7.0_mtk6750_u1/packages/apps/Settings        ###要移植的原代码目录###
#SRC=~/src/singleProjects/Settings        ###要移植的原代码目录###
RES_FOLDER=res_gome ##路径无法用正则表达式##
TARGET=$LOCAL_PATH/res_copy     ###资源拷贝过来后的存储路径###

FILE_ARRAY=(anim color drawable* layout* menu mipmap* raw xml)  ##以文件形式存在的资源##
CONTENT_ARRAY=(string attrs color dimen style )  ##以内容形式存在的资源##
DRAWABLE_ARRAY=(drawable-xxhdpi)    ##要抓取的图片##
DRAWABLE_XML_ONLY=true ##为true时，只拷贝drawable中的xml，不为true时拷贝所有图片资源##
STRING_ARRAY=(values values-zh-rCN)    ##要抓取的字符串##
strNum=${#STRING_ARRAY[@]}  ##数组长度#

####################################################################################


function init(){
    echo $SRC
    echo $TARGET 
    rm -rf ${TARGET}
    echo > search.log
    
    
    if [ ! -d "$TARGET/src" ]
    then
        mkdir -p $TARGET/src
    fi
   
    for data in ${STRING_ARRAY[@]}  
    do  
        sonTag="${TARGET}/${data}"
        if [ ! -d "$sonTag" ]
        then
            mkdir -p $sonTag
        fi
    done 
    
    if [ ! -d "$TARGET/layout" ] 
    then    
        mkdir -p "$TARGET/layout"
    fi
    
    if [ ! -d "$TARGET/drawable" ] 
    then    
        mkdir -p "$TARGET/drawable"
    fi
}

function getRes()
{
    echo "temp file: $TEMP_SEARCH_TAR_FILE"
    grep -Eo 'error: resource [A-Za-z0-9_\/]* ' build.log |\
    grep -Eo '[A-Za-z0-9_]*\/[A-Za-z0-9_]*' > $TEMP_SEARCH_TAR_FILE  ###eg. drawable/gome_bg_facecode_record_circle_3 ##
    while read LINE
    do
        echo "read line: ${LINE}"
        pre=$(echo "${LINE}"|cut -d / -f 1)
        suf=$(echo "${LINE}"|cut -d / -f 2)
        echo "pre: $pre"
        echo "suf: $suf"
 
        if echo "${FILE_ARRAY[@]}" | grep -w "${pre}" &>/dev/null; 
        then
            echo "file:---- $LINE"
            sonTag="${TARGET}/${pre}"
            #echo ${sonTag}
            if [ ! -d "${sonTag}" ]
            then
                mkdir -p ${sonTag}
            fi
            
            ##拷贝指定drawable类型##
            if [ ${pre} == "drawable" ]
            then 
                if [ "${DRAWABLE_XML_ONLY}" == "true" ] 
                then
                    find "${SRC}" -name "${suf}.xml" -type f -exec cp {} "${sonTag}" \;
                else
                    find "${SRC}" -name "${suf}.[A-Za-z0-9_]*" -type f -exec cp {} "${sonTag}" \;
                fi
            
                for picSrc in ${DRAWABLE_ARRAY[@]}  
                do  
                    #echo ${picSrc}  
                    sonSrc="${SRC}/${RES_FOLDER}/${picSrc}"
                    picTag="${TARGET}/${picSrc}"
                    if [ ! -d "$picTag" ]
                    then
                        mkdir -p $picTag
                    fi
                    find "${sonSrc}" -name "${suf}.[A-Za-z0-9_]*" -type f -exec cp {} "${picTag}" \;
                done 
            else
                find "${SRC}" -name "${suf}.[A-Za-z0-9_]*" -type f -exec cp {} "${sonTag}" \;
            fi
        fi
        ############内容########################################
        if echo "${CONTENT_ARRAY[@]}" | grep -w "${pre}" &>/dev/null;  
        then
            echo "content:  $LINE"          
            #grep -REo "<${pre} *name=\"${suf}\"\>[\s\S]*\<\/${pre}\>" ${SRC}/${RES_FOLDER}
            #grep -REo "<string name=\"[A-Za-z0-9_]*\">.*<\/string>" xxx.xml > a.txt  ###OK
            ###抓取布局中的字符串###
            if [ "${pre}" == "string" ]
            then
                content=${suf}
                if  grep -q name=\"${content}\" ${TARGET}/${STRING_ARRAY[num-1]}/strings.xml  ##OK
                then
                    echo "has copy ${content}"
                else
                    for data in ${STRING_ARRAY[@]}  
                    do  
                        sonSrc="${SRC}/${RES_FOLDER}/${data}/strings.xml"
                        sonTag="${TARGET}/${data}/strings.xml"
                        grep -rhEo "<${pre} name=\"${suf}\">.*<\/${pre}>" ${sonSrc} >> ${sonTag}  
                    done 
                fi
            else
                if  grep -q name=\"${suf}\" $TARGET/${pre}.xml
                then
                    echo "has copy ${suf}"
                else
                    grep -rhEo "<${pre} name=\"${suf}\">.*<\/${pre}>" ${SRC}/${RES_FOLDER}* >> $TARGET/${pre}.xml  ###OK  
                fi
            fi
       
        fi
       
    done  < $TEMP_SEARCH_TAR_FILE
    
    echo "read res completed !!"
}

##抓取###
##ERROR: /home/***/src/com/gome/settings/faceunlock/FaceUnlockScanActivity.java:64.13: WeakHandler cannot be resolved to a type#
function getSrc(){
    grep -Eo 'ERROR: .*[0-9]+\.[0-9]+\: [A-Za-z0-9_]* cannot be resolved to a type' build.log > $TEMP_SEARCH_TAR_FILE  
    while read LINE
    do
        echo $LINE
        fileName=$(echo "${LINE}"|cut -d " " -f 3)
        echo "fileName:--${fileName}.java"
        sonSrc=${SRC}/src
        echo "sonSrc: ${sonSrc}"
        sonTag=${TARGET}/src
        if [ ! -d  ${sonTag}/${fileName}.java ]
        then
            find "${sonSrc}" -name "${fileName}.java" -type f -exec cp {} "${sonTag}" \;
        fi
    done  < $TEMP_SEARCH_TAR_FILE
    echo "read src completed !!"
}

##抓取类中的字符串###
##ERROR: ERROR: /home/**/src/com/android/settings/localepicker/LocaleListEditor.java:214.44: locale_unselect_all cannot be resolved or is not a field###
##可能是布局文件：ERROR: /home/**/Settings/src/com/android/settings/datetime/DatePreferenceController.java:117.82: advance_data_pick_dialog cannot be resolved or is not a field##
##可能是drawable文件： ERROR: /home/××/src/com/android/settings/localepicker/LocaleListEditor.java:415.80: ic_gome_locale_delete cannot be resolved or is not a field##
function getStr(){
    echo "start getStr"
    grep -Eo 'ERROR: .*[0-9]+\.[0-9]+\: [A-Za-z0-9_]* cannot be resolved or is not a field' build.log > $TEMP_SEARCH_TAR_FILE  
    while read LINE
    do
        echo  $LINE
        content=$(echo "${LINE}"|cut -d " " -f 3)
        ##判断最后一个语言的字符串是否已经拷贝过来###
        
        # if [ find ${TARGET}/${STRING_ARRAY[num-1]} -name strings.xml | grep -w "name=\"${content}\"" &>/dev/null; ]
        ##if [ "'cat ${TARGET}/${STRING_ARRAY[num-1]}/strings.xml | grep -c name=\"${content}\"'"  != 0 ]; ##error
        if  grep -q name=\"${content}\" ${TARGET}/${STRING_ARRAY[num-1]}/strings.xml  ##OK
        then
            echo "has copy ${content}"
        else
            for data in ${STRING_ARRAY[@]}  
            do  
                sonSrc="${SRC}/${RES_FOLDER}/${data}/strings.xml"
                echo "sonSrc ${sonSrc}"
                sonTag="${TARGET}/${data}/strings.xml"
                grep -rhEo "<string name=\"${content}\">.*<\/string>" ${sonSrc} >> ${sonTag}  
            done 
        fi
        ##copy 布局文件####
        find "${SRC}/${RES_FOLDER}/layout" -name "${content}.xml" -type f -exec cp {} "${TARGET}/layout/" \;
        find "${SRC}/${RES_FOLDER}/drawable" -name "${content}.xml" -type f -exec cp {} "${TARGET}/drawable/" \;
        
    done  < $TEMP_SEARCH_TAR_FILE
    echo "read str completed !!"
}

function clearLog(){
    rm ${BUILD_LOG}
    rm ${TEMP_SEARCH_TAR_FILE}
}

init
getRes
getSrc
getStr
#clearLog