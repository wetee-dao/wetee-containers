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

export LIBC=musl;
export AGENT_INIT=no
export distro="alpine"
export ROOTFS_DIR="$(realpath kata-containers/tools/osbuilder/rootfs-builder/rootfs)"

sudo rm -rf "${ROOTFS_DIR}"
source hack/build_agent.sh

pushd kata-containers/tools/osbuilder/rootfs-builder
sudo -E USE_DOCKER=true LIBC=$LIBC AGENT_INIT=$AGENT_INIT AGENT_SOURCE_BIN=${DIR}/kata-containers/src/agent/target/x86_64-unknown-linux-$LIBC/release/kata-agent ./rootfs.sh "${distro}"
popd

source hack/build_image.sh