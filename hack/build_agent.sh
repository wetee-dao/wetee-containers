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

export ARCH="$(uname -m)"
# if [ "$ARCH" = "ppc64le" -o "$ARCH" = "s390x" ]; 
#     then export LIBC=gnu; 
#     else export LIBC=musl; 
# fi
# if [ "${ARCH}" == "ppc64le" ]; 
#     then export ARCH=powerpc64le
# fi

rustup target add "${ARCH}-unknown-linux-${LIBC}"

export seccomp_install_path="$DIR/libs/seccomp"
export LIBSECCOMP_LINK_TYPE=static
export LIBSECCOMP_LIB_PATH="${seccomp_install_path}/lib"
make -C kata-containers/src/agent