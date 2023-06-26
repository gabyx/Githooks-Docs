#!/bin/bash
# shellcheck disable=SC1090,SC1091,SC2015
# Test:
#   Run docs format hook on staged files

set -u

. "$GH_TEST_REPO/tests/general.sh"

function finish() {
    cleanRepos
}
trap finish EXIT

initGit || die "Init failed"
installHook "$GH_TEST_REPO/githooks/pre-commit" -and -path '*/1-format/.format-docs.sh' ||
    die "Install hook failed"

prettier --version || die "prettier not available."

function setupFiles() {
    echo -e "#  HEllo\n This is a text." >"A1.md"
}

setupFiles ||
    die "Could not make test sources."

git add . || die "Could not add files."
git diff --quiet || die "Should not have diffs"
out=$(git commit -a -m "Formatting files." 2>&1)
# shellcheck disable=SC2181
if [ $? -ne 0 ] ||
    ! echo "$out" | grep -qi "formatting.*A1.md"; then
    echo "Expected to have formatted all files."
    echo "$out"
    exit 1
fi

if git diff --quiet; then
    echo "Expected repository to be dirty. Formatted files  checked in."
    git status
    exit 1
fi

if ! git diff --quiet --cached; then
    echo "Formatted files are staged but should not."
    git status
    exit 1
fi

if [ "$(git status --porcelain | grep -c -E 'A.\..*')" != "1" ]; then
    echo "Expected repository to be dirty, formatting did not work."
    git status --porcelain
    exit 1
fi
