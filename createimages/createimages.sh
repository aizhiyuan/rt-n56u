#!/bin/sh

KERNELZ=images/zImage
COMP=lzma

rm -rf images

mkdir images

./mksquashfs_xz-4.0 romfs images/ramdisk -all-root -no-exports -noappend -nopad -noI -no-xattrs

./lzma_alone e -a1 -d25 zImage images/zImage.lzma

SIZE=`wc -c images/zImage.lzma | awk '{ print $1 }'` ; 
echo $((SIZE))
SIZE=$((SIZE))+64 ; 
echo $((SIZE))
DIV=$((SIZE))%16 ; 
echo $((DIV))
if [ $((DIV)) -gt 0 ] ; then 
	PAD=16-$((DIV)) ; 
	echo $((PAD))
	dd if=/dev/zero count=1 bs=$((PAD)) conv=sync 2> /dev/null | tr \\000 \\377 >> images/zImage.lzma ; 
fi

cat images/ramdisk >> images/zImage.lzma

ISIZE=`wc -c images/zImage.lzma | awk '{ print $1 }'`
echo $((ISIZE))
RSIZE=`wc -c images/ramdisk | awk '{ print $1 }'`
echo $((RSIZE))
KRN_SIZE=$((ISIZE))-$((RSIZE))+64

echo $((KRN_SIZE))
./mkimage -A mips -O linux -T kernel -C lzma -a 80000000 -e 0x8029ACA0 -k $((KRN_SIZE)) -n FX-6000 -V 1.00 00 -d images/zImage.lzma images/FX-6000_1.00.00-00.trx
