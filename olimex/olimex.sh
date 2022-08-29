#!/bin/bash

echo "start building kernel"

HERE=`pwd`

echo "processing u-boot-sunxi"
cd $HERE

if [ -d $HERE/u-boot-sunxi/.git ]; then
	echo "fetching u-boot-sunxi"
	cd u-boot-sunxi
	git fetch
else
	echo "cloning u-boot-sunxi"
	git clone -b sunxi-next --depth=1 git://github.com/jwrdegoede/u-boot-sunxi.git
	cd u-boot-sunxi
fi

echo "building uboot"

make A20-OLinuXino_MICRO_config
make

echo "creating uboot image"

echo "" > boot.cmd
echo "setenv kernel_addr_r 0x46000000 # 8M" >> boot.cmd
echo "setenv fdt_addr 0x49000000 # 2M" >> boot.cmd
echo "setenv fdt_high 0xffffffff # Load fdt in place instead of relocating" >> boot.cmd
echo "fatload mmc 0 ${kernel_addr_r} /uImage" >> boot.cmd
echo "setenv bootargs \"console=ttyS0,115200 ro root=/dev/mmcblk0p2 rootwait\"" >> boot.cmd
echo "fatload mmc 0 ${fdt_addr} /sun7i-a20-olinuxino-micro.dtb" >> boot.cmd
echo "bootm ${kernel_addr_r} - ${fdt_addr}" >> boot.cmd
./tools/mkimage -C none -A arm -T script -d boot.cmd boot.scr

pause

echo "processing linux kernel"
cd $HERE

echo "loading kernel sources 3.16-rc6"
if [ -e linux-3.16-rc6.tar.xz ]; then
	rm linux-3.16-rc6.tar.xz
fi
wget https://www.kernel.org/pub/linux/kernel/v3.x/testing/linux-3.16-rc6.tar.xz
#tar xf linux-3.16-rc6.tar.xz
rm linux-3.16-rc6.tar.xz

echo "building kernel"
cd linux-3.16-rc6/
make ARCH=arm sunxi_defconfig
make ARCH=arm menuconfig
#General setup -> Control Group support
#System Type -> Support for Large Physical Address Extension
#Device Drivers -> Block devices -&gt Loopback device support
#Virtualization
#Virtualization -> Kernel-based Virtual Machine (KVM) support (NEW)

echo "building uImage"
export PATH=$PATH:$HERE/u-boot-sunxi/tools
make ARCH=arm LOADADDR=0x40008000 uImage dtbs

echo "completed"
