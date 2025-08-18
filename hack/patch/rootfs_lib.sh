#!/usr/bin/env bash
#
# Copyright (c) 2018 SUSE
#
# SPDX-License-Identifier: Apache-2.0

build_rootfs() {
	local rootfs_dir=$1

    REPO_URL=https://deb.debian.org/debian
    info "mmdebstrap start--------------------------------------"
    info PACKAGES $PACKAGES
    info EXTRA_PKGS $EXTRA_PKGS

	if ! mmdebstrap --mode auto --arch "$DEB_ARCH" --variant required \
			--components="$REPO_COMPONENTS" \
			--include "$PACKAGES,$EXTRA_PKGS" "$OS_VERSION" "$rootfs_dir" "$REPO_URL"; then
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
