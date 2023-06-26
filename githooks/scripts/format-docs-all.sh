#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091

set -u
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/../common/log.sh"
. "$DIR/../common/parallel.sh"
. "$DIR/../common/docs-format.sh"

dir="${1:-}"
excludeIgnorePath="${2:-}"
fileGlob=${3:-$(getGeneralDocsFileGlob)}

[ -d "$dir" ] || die "Directory '$dir' does not exist."

read -r -p "Shall we really format all files? (No, yes, dry run) [N|y|d]: " what

dryRun="false"

if [ "$what" = "d" ]; then
    what="y"
    dryRun="true"
fi

if [ "$what" = "y" ]; then
    addArgs=()

    if [ "$dryRun" = "false" ]; then
        assertDocsFormatVersion "2.8.3" "3.0.0"
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
fi

exit 0
