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

export DEBIAN_DIR="$(realpath kata-containers/tools/osbuilder/rootfs-builder/debian)"

mv $DEBIAN_DIR/rootfs_lib.sh $DEBIAN_DIR/rootfs_lib_back.sh 
cp hack/patch/rootfs_lib.sh $DEBIAN_DIR/rootfs_lib.sh

pushd kata-containers/tools/osbuilder/rootfs-builder

sudo -E OS_VERSION=trixie LIBC=$LIBC AGENT_INIT=$AGENT_INIT AGENT_SOURCE_BIN=${DIR}/kata-containers/src/agent/target/x86_64-unknown-linux-$LIBC/release/kata-agent ./rootfs.sh "${distro}"
popd

rm $DEBIAN_DIR/rootfs_lib.sh 
mv $DEBIAN_DIR/rootfs_lib_back.sh $DEBIAN_DIR/rootfs_lib.sh 

# build image
source hack/build_image.sh

# build confidential image
sudo cp -r ./libs/pause_bundle  ${ROOTFS_DIR}
sudo cp ./libs/bins/* ${ROOTFS_DIR}/usr/local/bin/
export IMAGE_PREFIX="confidential-";
source hack/build_image.sh