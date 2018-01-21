#!/bin/bash

BUILD_START=$(date +"%s")
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'
kernel_version="R1"
kernel_name="AR_Beast™"
device_name="Z2_Plus"
zip_name="$kernel_name-$device_name-$kernel_version-$(date +"%Y%m%d")-$(date +"%H%M%S").zip"

export USE_CCACHE=1
export HOME="/home/ayushr1"
export CCACHE_DIR=/home/ayushr1/.ccache
export CONFIG_FILE="AR_Beast_z2_plus_defconfig"
export ARCH="arm64"
export KBUILD_BUILD_USER="Ayush"
export KBUILD_BUILD_HOST="Beast"
export TOOLCHAIN_PATH="${HOME}/AR_Beast/GCC-UBER-Prebuilts"
export CROSS_COMPILE=$TOOLCHAIN_PATH/bin/aarch64-linux-android-
export CONFIG_ABS_PATH="arch/${ARCH}/configs/${CONFIG_FILE}"
export objdir="$HOME/kernel/obj"
export sourcedir="$HOME/AR_Beast/AR_Beast-Kernel"
export image="$objdir/arch/$ARCH/boot/Image.gz-dtb"
export anykernel="$HOME/AR_Beast/ARB-Anykernel2"

compile() {
echo -e "$blue****************************************************************************"
echo "          Compiling $kernel_name-$device_name-$kernel_version         "
echo -e       "***************************************************************************$nocol"
  make O=$objdir  $CONFIG_FILE -j$(nproc --all)
  make O=$objdir -j$(nproc --all)
if ! [ -a $image ];
then
echo -e "$red Kernel Compilation failed! Fix the errors! $nocol"
exit 1
fi
}

clean() {
echo -e "$yellow****************************************************************************"
echo "          Cleaning        "
echo -e       "***************************************************************************$nocol"
  make O=$objdir CROSS_COMPILE=${CROSS_COMPILE}  $CONFIG_FILE -j$(nproc --all)
  make O=$objdir mrproper
  make O=$objdir clean
  rm -rf $anykernel/zImage
  rm -rf $image
}

module_stock(){
  rm -rf $anykernel/modules/
  mkdir $anykernel/modules
  find $objdir -name '*.ko' -exec cp -av {} $anykernel/modules/ \;
  # strip modules
  ${CROSS_COMPILE}strip --strip-unneeded $anykernel/modules/*
  cp -rf $image $anykernel/zImage
}
delete_zip(){
  cd $anykernel
  find . -name "*.zip" -type f
  find . -name "*.zip" -type f -delete
}
build_package(){
  zip -r9 UPDATE-AnyKernel2.zip * -x README UPDATE-AnyKernel2.zip
}
make_name(){
  mv UPDATE-AnyKernel2.zip $zip_name
}
copy_out(){
  mv $HOME/AR_Beast/ARB-Anykernel2/$zip_name $HOME/AR_Beast/out/ZukZ2/$zip_name
}
turn_back(){
cd $sourcedir
}
clean
compile
module_stock
delete_zip
build_package
make_name
copy_out
turn_back
clean
BUILD_END=$(date +"%s")
DIFF=$(($BUILD_END - $BUILD_START))
echo -e "$yellow****************************************************************************"
echo -e "$cyan Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
echo -e       "***************************************************************************$nocol"
