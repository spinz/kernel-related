#!/bin/sh

export KBUILD_BUILD_VERSION="DC_Kernel"

cd sgs-kernel 2>/dev/null
make clean -i
make dark_core_defconfig
nice -n 20 make -j4
cd ..

rm zImage
rm $KBUILD_BUILD_VERSION.tar
rm $KBUILD_BUILD_VERSION.zImage

cp sgs-kernel/arch/arm/boot/zImage .
tar cvf $KBUILD_BUILD_VERSION.tar zImage
cp zImage $KBUILD_BUILD_VERSION.zImage
ls -lh $KBUILD_BUILD_VERSION.zImage
