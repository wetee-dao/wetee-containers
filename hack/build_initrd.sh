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


pushd  kata-containers/tools/osbuilder/initrd-builder
sudo -E USE_DOCKER=true AGENT_INIT=$AGENT_INIT ./initrd_builder.sh "${ROOTFS_DIR}"
popd

pushd kata-containers/tools/osbuilder/initrd-builder
image="kata-containers-initrd.img"
install -m 0640 -D kata-containers-initrd.img "/opt/kata/wetee/${image}"
popd