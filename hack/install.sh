#!/bin/bash

# get shell path
SOURCE="$0"
while [ -h "$SOURCE"  ]; do
    DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /*  ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE"  )" && pwd  )"
cd $DIR/../

pushd kata-containers/src/runtime
# make && sudo -E "PATH=$PATH" PREFIX=/opt/kata make install
# sudo mkdir -p /etc/kata-containers/
sudo install -o root -g root -m 0640 /opt/kata/share/defaults/kata-containers/configuration.toml /etc/kata-containers
popd