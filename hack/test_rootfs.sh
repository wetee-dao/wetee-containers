#!/bin/bash

# get shell path
SOURCE="$0"
while [ -h "$SOURCE"  ]; do
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
DIR=$(realpath "$DIR/../")
cd $DIR

export ROOTFS_DIR="$(realpath kata-containers/tools/osbuilder/rootfs-builder/rootfs)"


# 挂载虚拟文件系统
# sudo mount -t proc proc $ROOTFS_DIR/proc
# sudo mount -t sysfs sysfs $ROOTFS_DIR/sys

# 进入 chroot
sudo chroot $ROOTFS_DIR /bin/bash

# sudo umount $ROOTFS_DIR/proc
# sudo umount -R $ROOTFS_DIR/sys