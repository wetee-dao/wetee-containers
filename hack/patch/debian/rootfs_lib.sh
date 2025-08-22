#!/usr/bin/env bash
#
# Copyright (c) 2018 SUSE
#
# SPDX-License-Identifier: Apache-2.0

build_rootfs() {
	local rootfs_dir=$1

	REPO_URL=http://cn.archive.ubuntu.com/ubuntu
    info "mmdebstrap start--------------------------------------"
    info packages $PACKAGES
    info extra_pkgs $EXTRA_PKGS

	if ! mmdebstrap --mode auto --arch "$DEB_ARCH" --variant required \
			--components="$REPO_COMPONENTS" \
			--include "$PACKAGES,$EXTRA_PKGS,apt-utils,ca-certificates,libcurl4" "$OS_VERSION" "$rootfs_dir" "$REPO_URL"\
			--customize-hook='mkdir -p $1/etc/apt/keyrings' \
			--customize-hook='wget -qO- https://download.01.org/intel-sgx/sgx_repo/ubuntu/intel-sgx-deb.key | tee $1/etc/apt/keyrings/intel-sgx-keyring.asc' \
			--customize-hook="echo 'deb [signed-by=/etc/apt/keyrings/intel-sgx-keyring.asc arch=amd64] https://download.01.org/intel-sgx/sgx_repo/ubuntu ${OS_VERSION} main' > $1/etc/apt/sources.list.d/intel-sgx.list" \
			--customize-hook='chroot $1 apt-get update' \
			--customize-hook='chroot $1 apt-get install libsgx-dcap-default-qpl'; then
		echo "ERROR: mmdebstrap failed, cannot proceed" && exit 1
	else
		echo "INFO: mmdebstrap succeeded"
	fi

	rm -rf "$rootfs_dir/var/run"
	ln -s /run "$rootfs_dir/var/run"
	cp --remove-destination /etc/resolv.conf "$rootfs_dir/etc"


	local dir="$rootfs_dir/etc/ssl/certs"
	mkdir -p "$dir"
	cp --remove-destination /etc/ssl/certs/ca-certificates.crt "$dir"

	# Reduce image size and memory footprint by removing unnecessary files and directories.
	rm -rf $rootfs_dir/usr/share/{bash-completion,bug,doc,info,lintian,locale,man,menu,misc,pixmaps,terminfo,zsh}

	# Minimal set of device nodes needed when AGENT_INIT=yes so that the
	# kernel can properly setup stdout/stdin/stderr for us
	pushd $rootfs_dir/dev
	MAKEDEV -v console tty ttyS null zero fd
	popd
}
