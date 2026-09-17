// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2024-2026 Elastic NV

//go:build linux && (amd64 || arm64)

package quark

// The cgo build flags for go-quark live here, separate from the bindings in
// quark.go. This allows for quark.go to be copied verbatim from the quark
// repository (copy-go target in the Makefile). The quark repository keeps its
// own cgo_flags.go file pointing at its build tree. The cgo_flags.go file in
// this repository compiles against the headers in include/ and links the
// pre-built per-architecture static library.
//
// All cgo CFLAGS in a package apply to every C preamble in the package, and
// all LDFLAGS are concatenated at link time, so these directives take effect
// for quark.go even though they are declared in a separate file. The build
// constraint above must match the one on quark.go.

/*
#cgo CFLAGS: -I${SRCDIR}/include
#cgo LDFLAGS: -Wl,--wrap=fmemopen
#cgo amd64 LDFLAGS: ${SRCDIR}/libquark_big_amd64.a
#cgo arm64 LDFLAGS: ${SRCDIR}/libquark_big_arm64.a
*/
import "C"
