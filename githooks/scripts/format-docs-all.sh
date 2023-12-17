#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

set -u
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/../common/log.sh"
. "$DIR/../common/parallel.sh"
. "$DIR/../common/docs-format.sh"

dryRun="true"
dir=""
excludeRegex=""
regex=$(getGeneralDocsFileRegex)

function help() {
    printError "Usage:" \
        "  [--force]                : Force the format." \
        "  [--exclude <regex> ]     : Exclude file with this regex." \
        "  [--include <pattern>]   : Regex pattern to include files." \
        "   --dir <path>            : In which directory to check files."
}

function parseArgs() {
    local prev=""

    for p in "$@"; do
        if [ "$p" = "--force" ]; then
            dryRun="false"
        elif [ "$p" = "--help" ]; then
            help
            return 1
        elif [ "$p" = "--dir" ]; then
            true
        elif [ "$prev" = "--dir" ]; then
            dir="$p"
        elif [ "$p" = "--exclude" ]; then
            true
        elif [ "$prev" = "--exclude" ]; then
            excludeRegex="$p"
        elif [ "$p" = "--include" ]; then
            true
        elif [ "$prev" = "--include" ]; then
            regex="$p"
        else
            printError "! Unknown argument \`$p\`"
            help
            return 1
        fi

        prev="$p"
    done
}

parseArgs "$@"

[ -d "$dir" ] || die "Directory '$dir' does not exist."

if [ "$dryRun" = "false" ]; then
    assertDocsFormatVersion "3.0.0" "4.0.0"
    printInfo "Formatting in '$dir with '$regex'."
else
    printInfo "Dry-run formatting in '$dir' with '$regex'."
fi

parallelForDir formatConfigsFile \
    "$dir" \
    "$regex" \
    "$excludeRegex" \
    "$dryRun" || die "Configs format failed."

exit 0
