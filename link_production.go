// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2026 Elastic NV

//go:build linux && (amd64 || arm64) && !quark_synthetic

package quark

/*
#cgo amd64 LDFLAGS: -Wl,--wrap=fmemopen ${SRCDIR}/libquark_big_amd64.a
#cgo arm64 LDFLAGS: -Wl,--wrap=fmemopen ${SRCDIR}/libquark_big_arm64.a
*/
import "C"
