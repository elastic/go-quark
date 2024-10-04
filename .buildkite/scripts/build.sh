#!/bin/bash

set -euo pipefail

# set expected arch name
ARCH="$(uname -m)"
if [ "${ARCH}" = "x86_64" ]; then
	ARCH=amd64
elif [ "${ARCH}" = "aarch64" ]; then
	ARCH=arm64
fi

echo "Building on ${ARCH}"

git submodule update --init --recursive

make -C src centos7

mv src/libquark_big.a libquark_big_${ARCH}.a
