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

export LIBC=gnu;
export distro="debian"
export ROOTFS_DIR="$(realpath kata-containers/tools/osbuilder/rootfs-builder/rootfs)"

sudo rm -rf "${ROOTFS_DIR}"
source hack/build_agent.sh

# export HTTP_PROXY=http://192.168.111.125:7890
# export HTTPS_PROXY=http://192.168.111.125:7890

export DEBIAN_DIR="$(realpath kata-containers/tools/osbuilder/rootfs-builder/debian)"
mv $DEBIAN_DIR/rootfs_lib.sh $DEBIAN_DIR/rootfs_lib_back.sh 
cp hack/patch/rootfs_lib.sh $DEBIAN_DIR/rootfs_lib.sh

pushd kata-containers/tools/osbuilder/rootfs-builder
sudo -E http_proxy=$HTTP_PROXY https_proxy=$HTTPS_PROXY OS_VERSION=bookworm LIBC=$LIBC AGENT_SOURCE_BIN=${DIR}/kata-containers/src/agent/target/x86_64-unknown-linux-$LIBC/release/kata-agent AGENT_INIT=yes ./rootfs.sh "${distro}"
popd

rm $DEBIAN_DIR/rootfs_lib.sh 
mv $DEBIAN_DIR/rootfs_lib_back.sh $DEBIAN_DIR/rootfs_lib.sh 