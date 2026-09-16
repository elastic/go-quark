ifeq ($(shell uname -m), x86_64)
	ARCH?= amd64
else ifeq ($(shell uname -m), aarch64)
	ARCH?= arm64
endif

SHIPPED_HEADERS:= src/compat.h
SHIPPED_HEADERS+= src/freebsd_queue.h
SHIPPED_HEADERS+= src/freebsd_tree.h
SHIPPED_HEADERS+= src/nova.h
SHIPPED_HEADERS+= src/quark.h

SHIPPED_GO:= src/go/quark/quark.go
SHIPPED_GO+= src/go/quark/quark_test.go

all: notice

notice:
	@echo "Generating NOTICE"
	go mod tidy
	go mod download
	go list -m -json all | go run go.elastic.co/go-licence-detector \
		-includeIndirect \
		-rules tools/notice/rules.json \
		-overrides tools/notice/overrides.json \
		-noticeTemplate tools/notice/NOTICE.txt.tmpl \
		-noticeOut NOTICE.txt \
		-depsOut ""

check-notice: notice
	@if git diff --name-only | grep "NOTICE.txt"; then \
		echo "NOTICE.txt differs from committed version; regenerate and commit."; \
	fi

copy-headers:
	cp $(SHIPPED_HEADERS) include/

# The Go sources live in the quark repo (src/go/quark) and are mirrored here
# verbatim. The cgo build flags are not part of quark.go: each repository keeps
# its own flags file (cgo_flags.go here, pointing at include/ and the prebuilt
# per-arch libquark_big_$(ARCH).a).
copy-go:
	@if grep -n '^#cgo ' $(SHIPPED_GO); then \
		echo "copy-go: upstream Go sources still carry cgo directives; they belong in a separate flags file (see cgo_flags.go)"; exit 1; \
	 fi
	cp $(SHIPPED_GO) .
	@if command -v gofmt >/dev/null 2>&1; then $(MAKE) --no-print-directory check-fmt; \
	 else echo "copy-go: gofmt not found, skipping format check; run 'make check-fmt' where Go is installed"; fi

# Fails if any Go file in the module root is not gofmt-clean or does not parse.
# The copied files are maintained upstream, so fix those in the quark repo.
check-fmt:
	@unformatted="$$(gofmt -l *.go)" || exit $$?; \
	 if [ -n "$$unformatted" ]; then \
		echo "check-fmt: not gofmt-clean: $$unformatted"; exit 1; \
	 fi

# This resets src/ to the committed revision, so stage a new quark commit
# (git add src) or ensure the committed revision is correct before running this.
update-quark:
	git submodule update --init --recursive
	$(MAKE) --no-print-directory copy-headers copy-go
	$(MAKE) -C src centos7 WITH_BTFHUB=y NO_GO=y
	mv src/libquark_big.a libquark_big_$(ARCH).a

.PHONY: notice check-notice copy-headers copy-go check-fmt update-quark
