#!/bin/bash

pwd=$PWD
DATE=$(date +'%d-%m-%Y')
BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'



echo -e "$red\n ##----------------------------------------------------------------------------##$nocol\n"
echo -e "$blue\n     #### ##     ## ##     ##  #######  ########  ########    ###    ##       "
echo -e "      ##  ###   ### ###   ### ##     ## ##     ##    ##      ## ##   ##       "
echo -e "      ##  #### #### #### #### ##     ## ##     ##    ##     ##   ##  ##       "
echo -e "      ##  ## ### ## ## ### ## ##     ## ########     ##    ##     ## ##       "
echo -e "      ##  ##     ## ##     ## ##     ## ##   ##      ##    ######### ##       "
echo -e "      ##  ##     ## ##     ## ##     ## ##    ##     ##    ##     ## ##       "
echo -e "     #### ##     ## ##     ##  #######  ##     ##    ##    ##     ## ########$nocol"
echo -e "$red\n ##----------------------------------------------------------------------------##$nocol\n"




#################
#==[ Export ]===#
#################

#===[ Most Editable ]===#

export DEFCONFIG=akame_defconfig
export NKD=willow
export CODENAME=willow
GCC_or_CLANG=2 #1 - GCC, 2 - CLANG
BUILD_KH=1 #1 - ENABLE, 2 - DISABLE


#===[ Editable ]===#

export SUBARCH=$ARCH
export USE_CCACHE=1
export CCACHE_DIR=~/.ccache
export JOBS="-j16"

#===[ Standart ]===#

export ANYKERNEL_DIR=AnyKernel3
export OUT_DIR=out
export ARCH=arm64
export UN=$HOME
export CONFIG=".config"

#########################
#===[ Smart Exports ]===#
#########################


if [ "$GCC_or_CLANG" -eq "1" ]
####-------####
#===[ GCC ]===#
####-------####
then	

#===[ Most Editable ]===#

GCC_PATH64=/usr
GCC_PATH32=/usr      	
GCC_BIN64=$GCC_PATH64/bin
GCC_BIN32=$GCC_PATH32/bin

#===[ Editable ]===#


GCC_PREF64=aarch64-linux-gnu
GCC_PREF32=arm-linux-gnueabi
GCC_PREFIX64=aarch64-linux-gnu-
GCC_PREFIX32=arm-linux-gnueabi-
GCC_LIB32=$GCC_PATH32/lib/$GCC_PREF32	
GCC_LIB64=$GCC_PATH64/lib/$GCC_PREF64	

#===[ Standart ]===#

GCC_LIBS=$GCC_LIB64:$GCC_LIB32
GCC_BINS=$GCC_BIN64:$GCC_BIN32
export LD_LIBRARY_PATH=$GCC_LIBS:$LD_LIBRARY_PATH
export PATH=$GCC_BINS:$PATH
export CROSS_COMPILE=$GCC_PREFIX64
export CROSS_COMPILE_ARM32=$GCC_PREFIX32


####---------####
#===[ Clang ]===#
####---------####
else	

#===[ Most Editable ]===#

CLANG_PATH=/usr
CLANG_BIN=$CLANG_PATH/lib/llvm-11/bin
GCC_PATH64=/usr
GCC_PATH32=/usr
GCC_BIN64=$GCC_PATH64/bin
GCC_BIN32=$GCC_PATH32/bin

#===[ Editable ]===#

GCC_PREF64=aarch64-linux-gnu          
GCC_PREF32=arm-linux-gnueabi           
GCC_PREFIX64=aarch64-linux-gnu-			
GCC_PREFIX32=arm-linux-gnueabi-
CLANG_LIB32=$CLANG_PATH/lib/llvm-11/lib
CLANG_LIB64=$CLANG_PATH/lib/llvm-11/lib64
GCC_LIB64=$GCC_PATH64/lib/$GCC_PREF64
GCC_LIB32=$GCC_PATH32/lib/$GCC_PREF32

#===[ Standart ]===#

GCC_BINS=$GCC_BIN64:$GCC_BIN32
GCC_LIBS=$GCC_LIB64:$GCC_LIB32
CLANG_LIBS=$CLANG_LIB64:$CLANG_LIB32
export LD_LIBRARY_PATH=$CLANG_LIBS:$GCC_LIBS:$LD_LIBRARY_PATH
export PATH=$CLANG_BIN:$GCC_BINS:$PATH
export CROSS_COMPILE=$GCC_PREFIX64
export CLANG_TRIPLE=$GCC_PREFIX64
export CROSS_COMPILE_ARM32=$GCC_PREFIX32
VALUES="OBJCOPY=llvm-objcopy \
        OBJDUMP=llvm-objdump \
        STRIP=llvm-strip \
	    NM=llvm-nm \
        AR=llvm-ar \
	    AS=llvm-as"
fi




echo -e "$yellow\n ##============================================================================##"
echo -e " ##========================= Build Kernel From Source =========================##"
echo -e " ##============================================================================##$nocol\n"

if [ "$GCC_or_CLANG" -eq "1" ]
####-------####
#===[ GCC ]===#
####-------####
then	


    make $DEFCONFIG all dtbo.img firmware_install modules_install \
	CC=gcc \
	PATH=${PATH} \
	CROSS_COMPILE=${CROSS_COMPILE} \
	CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
	ARCH=${ARCH} \
	O=${OUT_DIR} \
	INSTALL_MOD_PATH=. \
	${JOBS}
	
	
####---------####
#===[ Clang ]===#
####---------####
else	


    make $DEFCONFIG all dtbo.img firmware_install modules_install \
	CC=clang \
	PATH=${PATH} \
	CLANG_TRIPLE=${CLANG_TRIPLE} \
	CROSS_COMPILE=${CROSS_COMPILE} \
	CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
	ARCH=${ARCH} \
	O=${OUT_DIR} \
	${JOBS} \
    INSTALL_MOD_PATH=. \
    $VALUES
fi




if [ "$BUILD_KH" -eq "1" ]

#####################
#===[ Biuild KH ]===#
#####################
then

echo -e "$yellow\n ##============================================================================##"
echo -e " ##=========================== Build Kernel Headers ===========================##"
echo -e " ##============================================================================##$nocol\n"

sudo rm -rf /${UN}/kernel-headers/kernel-headers/

sudo rm -rf /${UN}/tmp 

rm -rf /${UN}/kernel-headers-${CODENAME}.tar.xz

mkdir /${UN}/kernel-headers/kernel-headers/

cp -r * /${UN}/kernel-headers/kernel-headers/

cd /${UN}/kernel-headers/kernel-headers/

if [ "$GCC_or_CLANG" -eq "1" ]
####-------####
#===[ GCC ]===#
####-------####
then	


    make prepare \
	CC=gcc \
	PATH=${PATH} \
	CROSS_COMPILE=${CROSS_COMPILE} \
	CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
	ARCH=${ARCH} \
	O=${OUT_DIR} \
    INSTALL_MOD_PATH=. \
    ${JOBS} 
	
	
####---------####
#===[ Clang ]===#
####---------####
else	

    
    make  prepare \
	CC=clang \
	PATH=${PATH} \
	CLANG_TRIPLE=${CLANG_TRIPLE} \
	CROSS_COMPILE=${CROSS_COMPILE} \
	CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
	ARCH=${ARCH} \
	O=${OUT_DIR} \
	${JOBS} \
    INSTALL_MOD_PATH=. \
    $VALUES
fi

mkdir /${UN}/tmp 

cp -r arch/arm* Makefile ${OUT_DIR}/modules.* ${OUT_DIR}/scripts/mod/modpost ${OUT_DIR}/scripts/genksyms/genksyms  include scripts drivers/misc /${UN}/tmp 

rm -rf * 

cp -r /${UN}/tmp/* $PWD 

mv modpost scripts/mod/

mv genksyms scripts/genksyms/

rm -rf /${UN}/tmp 

mkdir arch 

cp -r arm* arch 

rm -rf arm* 

mkdir drivers 

cp -r misc drivers 

rm -rf misc

cd /${UN}/kernel-headers/kernel-headers/

cd /${UN}/

sudo dpkg-deb --build kernel-headers kernel-headers-${CODENAME}.deb

ls



echo -e "$yellow\n ##============================================================================##"
echo -e " ##===================== Creating A Flashable *.zip Archive ===================##"
echo -e " ##============================================================================##$nocol\n"


cd /${UN}/${NKD}

rm -rf AnyKernel3

cp /${UN}/AnyKernel3 /${UN}/${NKD} -r

	
if [ "$GCC_or_CLANG" -eq "1" ]
####-------####
#===[ GCC ]===#
####-------####
then	


    KERNEL_NAME=$(make kernelrelease \
        CC=gcc
        PATH=${PATH} \
        CROSS_COMPILE=${CROSS_COMPILE} \
        CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
        ARCH=${ARCH} \
        O=${OUT_DIR} \
        INSTALL_MOD_PATH=. \
        ${JOBS} | grep +)
	
	
####---------####
#===[ Clang ]===#
####---------####
else	

    
    KERNEL_NAME=$(make kernelrelease \
        CC=clang \
        PATH=${PATH} \
        CLANG_TRIPLE=${CLANG_TRIPLE} \
        CROSS_COMPILE=${CROSS_COMPILE} \
        CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
        ARCH=${ARCH} \
        O=${OUT_DIR} \
        ${JOBS} \
        INSTALL_MOD_PATH=. \
        $VALUES | grep +)
fi


        


mkdir -p ${ANYKERNEL_DIR}/modules/system/lib/modules/${KERNEL_NAME}/kernel
mkdir -p ${ANYKERNEL_DIR}/modules/system/etc/firmware


cd /${UN}/${NKD}


#===[ COPYNG ]===#


cd out && cp $(find -name *.ko) --parents ../${ANYKERNEL_DIR}/modules/system/lib/modules/${KERNEL_NAME}/kernel
cp $(find -name *.bin) ../${ANYKERNEL_DIR}/modules/system/etc/firmware
cp $(find -name *.fw) ../${ANYKERNEL_DIR}/modules/system/etc/firmware
cp modules.* ../${ANYKERNEL_DIR}/modules/system/lib/modules/ && cd ..
 ${ANYKERNEL_DIR}
cp $(find -name dtbo.img) ${ANYKERNEL_DIR}


#===[ EDITABLE ]===#

cp $(find -name Image.gz-dtb) ${ANYKERNEL_DIR}
#cp $(find -name Image.gz) ${ANYKERNEL_DIR}
#cp $(find -name dtb) ${ANYKERNEL_DIR}


#===[ ZIPPING ]===#


cd ${ANYKERNEL_DIR} && zip -r -9 AkameKernel-${CODENAME}-$(date +%d-%m-%y).zip * -x .git README.md *placeholder

######################
#===[ TIME BUILD ]===#
######################

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$blue Kernel compiled on $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds$nocol"





#################
#===[Skip KH]===#
#################
else

echo -e "$yellow\n ##============================================================================##"
echo -e " ##===================== Creating A Flashable *.zip Archive ===================##"
echo -e " ##============================================================================##$nocol\n"


cd /${UN}/${NKD}

rm -rf AnyKernel3

cp /${UN}/AnyKernel3 /${UN}/${NKD} -r

	
if [ "$GCC_or_CLANG" -eq "1" ]
####-------####
#===[ GCC ]===#
####-------####
then	


    KERNEL_NAME=$(make kernelrelease \
        CC=gcc
        PATH=${PATH} \
        CROSS_COMPILE=${CROSS_COMPILE} \
        CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
        ARCH=${ARCH} \
        O=${OUT_DIR} \
        ${JOBS} | grep +)
	
	
####---------####
#===[ Clang ]===#
####---------####
else	

    
    KERNEL_NAME=$(make kernelrelease \
        CC=clang \
        PATH=${PATH} \
        CLANG_TRIPLE=${CLANG_TRIPLE} \
        CROSS_COMPILE=${CROSS_COMPILE} \
        CROSS_COMPILE_ARM32=${CROSS_COMPILE_ARM32} \
        ARCH=${ARCH} \
        O=${OUT_DIR} \
        ${JOBS} \
        $VALUES | grep +)
fi


        


mkdir -p ${ANYKERNEL_DIR}/modules/system/lib/modules/${KERNEL_NAME}/kernel
mkdir -p ${ANYKERNEL_DIR}/modules/system/etc/firmware


cd /${UN}/${NKD}


#===[ COPYNG ]===#


cd out && cp $(find -name *.ko) --parents ../${ANYKERNEL_DIR}/modules/system/lib/modules/${KERNEL_NAME}/kernel
cp $(find -name *.bin) ../${ANYKERNEL_DIR}/modules/system/etc/firmware
cp $(find -name *.fw) ../${ANYKERNEL_DIR}/modules/system/etc/firmware
cp modules.* ../${ANYKERNEL_DIR}/modules/system/lib/modules/ && cd ..
 ${ANYKERNEL_DIR}
cp $(find -name dtbo.img) ${ANYKERNEL_DIR}


#===[ EDITABLE ]===#

cp $(find -name Image.gz-dtb) ${ANYKERNEL_DIR}
#cp $(find -name Image.gz) ${ANYKERNEL_DIR}
#cp $(find -name dtb) ${ANYKERNEL_DIR}


#===[ ZIPPING ]===#


cd ${ANYKERNEL_DIR} && zip -r -9 AkameKernel-${CODENAME}-$(date +%d-%m-%y).zip * -x .git README.md *placeholder

######################
#===[ TIME BUILD ]===#
######################

BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$blue Kernel compiled on $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds$nocol"

fi





