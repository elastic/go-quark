#!/bin/bash

set -euo pipefail

# Build libquark_big.a for all supported architectures

git submodule update --init --recursive

for ARCH in amd64
do
	ARCH=$ARCH make -C src centos7
	mv src/libquark_big.a libquark_big_${ARCH}.a
done

