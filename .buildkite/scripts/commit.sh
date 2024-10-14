#!/bin/bash

set -euo pipefail

# These headers must be included in this repo directly for cgo compilation of go-quark
header_list=(
	compat.h \
	freebsd_queue.h \
	freebsd_tree.h \
	quark.h \
)

BOT_NAME=${BOT_NAME:-"buildkite[bot]"}
BOT_ID=${BOT_ID:-"20291210"}
BOT_EMAIL=${BOT_EMAIL:-"${BOT_ID}+${BOT_NAME}@users.noreply.github.com"}

function download {
	buildkite-agent artifact download "$1" "$2"
}

if [ -z "${BUILDKITE}" ]; then
	echo "This script doesn't appear to be running in buildkite; refusing to commit"
	exit 1
fi

# Commits only need to be done if:
# (1) this is a PR build
# (2) the quark submodule has changed compared to the base branch
if [ -z "${BUILDKITE_PULL_REQUEST}" ]; then
	echo "Skipping commit for non-PR build"
	exit 0
fi

if git diff --exit-code --quiet ${BUILDKITE_PULL_REQUEST_BASE_BRANCH} -- ./src; then
	echo "Skipping commit; no change detected in quark submodule"
	exit 0
fi

for ARCH in amd64 arm64; do
	download libquark_big_${ARCH}.a .
done

for file in "${header_list[@]}"; do
	cp src/${file} include/
done


git config --global user.name "${BOT_NAME}"
git config --global user.email "${BOT_EMAIL}"

git config --global credential.https://github.com.username token
git config --global credential.https://github.com.helper '!echo \"password=\$(cat /run/secrets/VAULT_GITHUB_TOKEN)\";'

git add libquark_big_{amd64,arm64}.a include/*.h

git commit -m "Auto-update files by Buildkite"

git push origin HEAD:"${BUILDKITE_BRANCH}"
