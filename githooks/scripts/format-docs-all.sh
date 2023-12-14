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
excludeIgnorePath=""
fileGlob=$(getGeneralDocsFileGlob)

function help() {
    printError "Usage:" \
        "  [--force]                      : Force the format." \
        "  [--exclude-ignore-path <path>] : Exclude file ignore path." \
        "  [--glob-pattern <pattern>]     : Glob pattern format files." \
        "   --dir <path>                  : In which directory to format files."
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
        elif [ "$p" = "--exclude-ignore-path" ]; then
            true
        elif [ "$prev" = "--exclude-ignore-path" ]; then
            excludeIgnorePath="$p"
        elif [ "$p" = "--glob-pattern" ]; then
            true
        elif [ "$prev" = "--glob-pattern" ]; then
            fileGlob="$p"
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

addArgs=()

if [ "$dryRun" = "false" ]; then
    assertConfigsFormatVersion "3.0.0" "4.0.0"
    addArgs+=(--write)
    printInfo "Formatting in '$dir with '$fileGlob'."
else
    printInfo "Dry-run formatting in '$dir' with '$fileGlob'."
    addArgs+=(--list-different)
fi

if [ -n "$excludeIgnorePath" ]; then
    [ -f "$excludeIgnorePath" ] || die "Ignore file '$excludeIgnorePath' for prettier does not exist."

    addArgs+=(--ignore-path "$excludeIgnorePath")
fi

prettierExe="pprettier"
if ! command -v "$prettierExe" &>/dev/null; then
    prettierExe="prettier"
fi

# Format with no config -> search directory tree upwards.
(cd "$dir" && "$prettierExe" "${addArgs[@]}" "$fileGlob") ||
    die "Formatting in '$dir' with '$fileGlob' failed."

exit 0
