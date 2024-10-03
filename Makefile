.PHONY: notice
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

.PHONY: check-notice
check-notice: notice
	@if git diff --name-only | grep "NOTICE.txt"; then \
		echo "NOTICE.txt differs from committed version; regenerate and commit."; \
	fi
