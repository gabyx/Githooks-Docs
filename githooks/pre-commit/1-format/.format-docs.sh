#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
ROOT_DIR="$DIR/../../.."
. "$ROOT_DIR/githooks/common/export-staged.sh"
. "$ROOT_DIR/githooks/common/parallel.sh"
. "$ROOT_DIR/githooks/common/docs-format.sh"
. "$ROOT_DIR/githooks/common/stage-files.sh"
. "$ROOT_DIR/githooks/common/log.sh"

assertStagedFiles || die "Could not assert staged files."

printHeader "Running hook: Prettier format ..."

assertDocsFormatVersion "3.0.0" "4.0.0"

regex=$(getGeneralDocsFileRegex) || die "Could not get docs file regex."
parallelForFiles formatDocsFile \
    "$STAGED_FILES" \
    "$regex" \
    "false" || die "Prettier format failed."
