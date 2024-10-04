// SPDX-License-Identifier: Apache-2.0
// Copyright (c) 2024 Elastic NV

//go:build tools
// +build tools

// This package contains the tool dependencies of the project.

package tools

import (
	_ "github.com/elastic/go-licenser"
	_ "go.elastic.co/go-licence-detector"
)
