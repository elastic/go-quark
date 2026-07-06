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

update-quark: copy-headers
	git submodule update --init --recursive
	make -C src centos7 WITH_BTFHUB=y NO_GO=y
	mv src/libquark_big.a libquark_big_$(ARCH).a

.PHONY: notice check-notice copy-headers update-quark
