#!/bin/bash

set -euo pipefail

# Commit modified .a files to the same branch that was built

function download {
	buildkite-agent artifact download "$1" "$2"
}

for ARCH in amd64 arm64; do
	download libquark_big_${ARCH}.a .
done

# If there are no changes, don't commit
if ! git diff --name-only HEAD^ HEAD | grep -q -E '\.a$'; then
	echo "No changes detected"
	exit 0
fi

git config --global user.name "buildkite-bot"
git config --global user.email "buildkite-bot@noreply.elastic.co"

git add --force libquark_big_{amd64,arm64}.a

git commit -m "Auto-update .a files by Buildkite"

if test -z "${BUILDKITE_BRANCH}"; then
	echo "This script doesn't appear to be running in buildkite"
	exit 1
fi

git push origin HEAD:"${BUILDKITE_BRANCH}"
