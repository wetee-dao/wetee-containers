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

export seccomp_install_path="$DIR/../libs/seccomp"
export gperf_install_path="$DIR/../libs/gperf"

mkdir -p ${seccomp_install_path} ${gperf_install_path}
pushd kata-containers/ci
sudo -E ./install_libseccomp.sh ${seccomp_install_path} ${gperf_install_path}
export LIBSECCOMP_LIB_PATH="${seccomp_install_path}/lib"
popd