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

# sudo install -o root -g root -m 0550 -t "${ROOTFS_DIR}/usr/bin" "${ROOTFS_DIR}/../../../../src/agent/target/x86_64-unknown-linux-musl/release/kata-agent"

if [[ "${AGENT_INIT}" == "no" ]]; then
sudo install -o root -g root -m 0440 "${ROOTFS_DIR}/../../../../src/agent/kata-agent.service" "${ROOTFS_DIR}/usr/lib/systemd/system/"
sudo install -o root -g root -m 0440 "${ROOTFS_DIR}/../../../../src/agent/kata-containers.target" "${ROOTFS_DIR}/usr/lib/systemd/system/"
fi

pushd  kata-containers/tools/osbuilder/image-builder
sudo -E USE_DOCKER=true AGENT_INIT=$AGENT_INIT ./image_builder.sh "${ROOTFS_DIR}"
popd

pushd kata-containers/tools/osbuilder/image-builder
# commit="$(git log --format=%h -1 HEAD)"
# date="$(date +%Y-%m-%d-%T.%N%z)"
image="kata-${IMAGE_PREFIX}containers.img"
install -m 0640 -D kata-containers.img "/opt/kata/wetee/${image}"
# (cd /opt/kata/share/wetee/ && sudo ln -sf "$image" kata-containers.img)
popd