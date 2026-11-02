// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Elastic NV

//go:build linux && (amd64 || arm64) && quark_synthetic

package quark

// The cgo build flags for the quark_synthetic build tag, the counterpart of
// cgo_flags.go. They link libquark_big_synthetic_$(ARCH).a, built by the
// update-quark-synthetic Makefile target, which contains the probe-free
// synthetic queue used by tests and benchmarks. The synthetic declarations in
// quark.h are only visible with WITH_SYNTHETIC defined. The quark repository
// keeps the matching define in its own cgo_flags_synthetic.go.

/*
#cgo CFLAGS: -I${SRCDIR}/include -DWITH_SYNTHETIC
#cgo LDFLAGS: -Wl,--wrap=fmemopen
#cgo amd64 LDFLAGS: ${SRCDIR}/libquark_big_synthetic_amd64.a
#cgo arm64 LDFLAGS: ${SRCDIR}/libquark_big_synthetic_arm64.a
*/
import "C"
