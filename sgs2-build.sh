#!/bin/sh

export ARCH=arm
export CROSS_COMPILE=/home/ficeto/SC_Kernel/arm-eabi/bin/arm-none-eabi-
export LOCALVERSION=""
export KBUILD_BUILD_VERSION="SC_Kernel"

# initramfs codes
# XWKF3: -I9100XWKF3-CL276555
# XXKG1: -I9100XXKG1-CL349526

TAR_NAME=$PWD/$KBUILD_BUILD_VERSION.tar
INITRAMFS_SOURCE=`readlink -f initramfs`
INITRAMFS_TMP="/tmp/initramfs-source"

rm -rf $INITRAMFS_TMP
cp -ax $INITRAMFS_SOURCE $INITRAMFS_TMP
find $INITRAMFS_TMP -name .git -exec rm -rf {} \;

adb shell sync

cd sgs2-kernel/
make clean -i
make ficeto_defconfig

#nice -n 20 make -j4 modules || exit 1
#find -name '*.ko' -exec cp -av {} $INITRAMFS_TMP/lib/modules/ \;
#find -name '*.ko' -exec ls -lh {} \;

cd $INITRAMFS_TMP
find | fakeroot cpio -H newc -o > $INITRAMFS_TMP.cpio 2>/dev/null
ls -lh $INITRAMFS_TMP.cpio
cd -

nice -n 20 make -j4 zImage CONFIG_INITRAMFS_SOURCE="$INITRAMFS_TMP.cpio" || exit 1
cd arch/arm/boot/
tar cf $TAR_NAME zImage && ls -lh $TAR_NAME

adb push zImage /data/local/tmp/
adb shell su -c "cat /data/local/tmp/zImage > /dev/block/mmcblk0p5"
adb shell "sync; reboot phone"
