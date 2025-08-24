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
export AGENT_INIT=yes
export distro="debian"
export ROOTFS_DIR="$(realpath kata-containers/tools/osbuilder/rootfs-builder/rootfs)"

sudo rm -rf "${ROOTFS_DIR}"
source hack/build_agent.sh

export BUILDER_DIR="$(realpath kata-containers/tools/osbuilder/rootfs-builder)"

mv $BUILDER_DIR/debian $BUILDER_DIR/debian_back
cp -r hack/patch/debian $BUILDER_DIR/

pushd kata-containers/tools/osbuilder/rootfs-builder
sudo -E OS_VERSION=noble LIBC=$LIBC AGENT_INIT=$AGENT_INIT AGENT_SOURCE_BIN=${DIR}/kata-containers/src/agent/target/x86_64-unknown-linux-$LIBC/release/kata-agent ./rootfs.sh "${distro}"
popd

rm -rf $BUILDER_DIR/debian
mv $BUILDER_DIR/debian_back $BUILDER_DIR/debian

# build image
sudo cp $DIR/libos-entry/base-docker/ego/sgx_default_qcnl.conf ${ROOTFS_DIR}/etc
sudo cp $DIR/libs/bins/sgx-verify ${ROOTFS_DIR}/usr/local/bin/
source hack/build_image.sh

# build confidential image
sudo cp -r ./libs/pause_bundle  ${ROOTFS_DIR}
sudo cp libs/bins/* ${ROOTFS_DIR}/usr/local/bin/
export IMAGE_PREFIX="confidential-";
source hack/build_image.sh