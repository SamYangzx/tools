#!/bin/bash

########�ű�ԭ�� 
##���������ɵ�log�洢��build.log�ļ��У�����ȱ�����Դ����������ȥԭ����Դ��·��ץȡ��ص���Դ�������� ${TARGET} Ŀ¼��
##
##ʹ��˵����
##1.Ŀǰ��֧��theme,style����ֲ��
##2.ʹ��ǰ�����޸�SRCֵ��������������ʵ����Ҫ���е���
##3.ץȡ���ļ�����ȡ��${TARGET}Ŀ¼�У�����ʵ����������Ӧλ��
##

LOCAL_PATH=`pwd`
BUILD_LOG=$LOCAL_PATH/build.log     ###������󱣴��log�ļ�������� mm -B -j8 2>&1 | tee build.log ���������ɵ��ļ�һ��####
SEARCH_TAR="error: resource "       ###ƥ��ԭ��###
TEMP_SEARCH_TAR_FILE=$LOCAL_PATH/search.log     ###���ɵ���ʱ�ļ�###
SRC=~/src/build/gm_7.0_mtk6750_u1/packages/apps/Settings        ###Ҫ��ֲ��ԭ����Ŀ¼###
RES_FOLDER=res ##·���޷���������ʽ##
TARGET=$LOCAL_PATH/res_copy     ###��Դ����������Ĵ洢·��###

FILE_ARRAY=(anim color drawable* layout* menu mipmap* raw xml)  ##���ļ���ʽ���ڵ���Դ##
CONTENT_ARRAY=(string attrs color dimen style )  ##��������ʽ���ڵ���Դ##
DRAWABLE_ARRAY=(drawable-xhdpi drawable-xxhdpi drawable-xxxhdpi)    ##Ҫץȡ��ͼƬ##
DRAWABLE_XML_ONLY=true ##Ϊtrueʱ��ֻ����drawable�е�xml����Ϊtrueʱ��������ͼƬ��Դ##
STRING_ARRAY=(values values-zh-rCN )    ##Ҫץȡ���ַ���##
strNum=${#STRING_ARRAY[@]}  ##���鳤��#

####################################################################################


function init(){
    echo $SRC
    echo $TARGET 
    echo ${FILE_ARRAY[1]}
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
}

function getRes()
{
    grep -Eo 'error: resource [A-Za-z0-9_\/]* ' build.log |\
    grep -Eo '[A-Za-z0-9_]*\/[A-Za-z0-9_]*' > $TEMP_SEARCH_TAR_FILE  ###eg. drawable/gome_bg_facecode_record_circle_3 ##
    while read LINE
    do
        echo $LINE
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
            
            ##����ָ��drawable����##
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
        ############����########################################
        if echo "${CONTENT_ARRAY[@]}" | grep -w "${pre}" &>/dev/null;  
        then
            echo "content:  $LINE"          
            #grep -REo "<${pre} *name=\"${suf}\"\>[\s\S]*\<\/${pre}\>" ${SRC}/${RES_FOLDER}
            #grep -REo "<string name=\"[A-Za-z0-9_]*\">.*<\/string>" xxx.xml > a.txt  ###OK
            ###ץȡ�����е��ַ���###
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

##ץȡ###
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

##ץȡ���е��ַ���###
##ERROR: ERROR: /home/**/src/com/android/settings/localepicker/LocaleListEditor.java:214.44: locale_unselect_all cannot be resolved or is not a field###
function getStr(){
    grep -Eo 'ERROR: .*[0-9]+\.[0-9]+\: [A-Za-z0-9_]* cannot be resolved or is not a field' build.log > $TEMP_SEARCH_TAR_FILE  
    while read LINE
    do
        echo $LINE
        content=$(echo "${LINE}"|cut -d " " -f 3)
        ##�ж����һ�����Ե��ַ����Ƿ��Ѿ���������###
        
        # if [ find ${TARGET}/${STRING_ARRAY[num-1]} -name strings.xml | grep -w "name=\"${content}\"" &>/dev/null; ]
        ##if [ "'cat ${TARGET}/${STRING_ARRAY[num-1]}/strings.xml | grep -c name=\"${content}\"'"  != 0 ]; ##error
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
    done  < $TEMP_SEARCH_TAR_FILE
    echo "read str completed !!"
}

init
getRes
getSrc
getStr