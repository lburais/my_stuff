qemu-system-arm -M versatilepb -cpu arm1176 -m 256 -hda rootfs.ext2 -kernel zImage -append "root=/dev/sda" -serial stdio
