#!/bin/bash

set -euo pipefail

# Commit modified .a files to the same branch that was built

BOT_NAME=${BOT_NAME:-"buildkite-bot"}
BOT_EMAIL=${BOT_EMAIL:-"buildkite-bot@noreply.elastic.co"}

function download {
	buildkite-agent artifact download "$1" "$2"
}

for ARCH in amd64; do
	download libquark_big_${ARCH}.a .
done

# If there are no changes, don't commit
if ! git diff --name-only HEAD | grep -q -E '\.a$'; then
	echo "No changes detected"
	exit 0
fi

# Don't commit if the last commit is from the bot, to avoid infinite loop of builds
if test "$(git log -1 --pretty=format:'%ae')" = "${BOT_EMAIL}"; then
	echo "last commit from bot"
	exit 0
fi

if test -z "${BUILDKITE}"; then
	echo "This script doesn't appear to be running in buildkite; refusing to commit"
	exit 1
fi

git config --global user.name "${BOT_NAME}"
git config --global user.email "${BOT_EMAIL}"

git config --global credential.https://github.com.username token
git config --global credential.https://github.com.helper '!echo \"password=\$(cat /run/secrets/VAULT_GITHUB_TOKEN)\";'

git add libquark_big_amd64.a

git commit -m "Auto-update .a files by Buildkite"

git push origin HEAD:"${BUILDKITE_BRANCH}"
