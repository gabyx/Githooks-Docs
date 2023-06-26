#!/bin/bash
# shellcheck disable=SC1090,SC1091,SC2015


DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
. "$DIR/log.sh"
. "$DIR/version.sh"
. "$DIR/regex-docs.sh"

# Assert that 'prettier' (`=$1`) has version `[$2, $3)`.
function assertDocsFormatVersion() {
    local expectedVersionMin="$1"
    local expectedVersionMax="$2"
    local exe="${3:-prettier}"

    command -v "$exe" &>/dev/null ||
        die "Tool '$exe' is not installed."

    local version
    version=$("$exe" --version | sed -E "s@v?([0-9]+\.[0-9]+\.[0-9]+).*@\1@")

    versionCompare "$version" ">=" "$expectedVersionMin" &&
        versionCompare "$version" "<" "$expectedVersionMax" ||
        die "Version of 'prettier' is '$version' but should be '[$expectedVersionMin, $expectedVersionMax)'."

    printInfo "Version: prettier '$version'."

    return 0
}

# Format a shell file inplace.
function formatDocsFile() {
    local file="$1"
    local prettierExe="pprettier"

    if ! command -v "$prettierExe" &>/dev/null; then
        prettierExe="prettier"
    fi

    printInfo " - ✍ Formatting file: '$file'"
    "$prettierExe" --write "$file" 1>&2 ||
        {
            printError "'$prettierExe' failed for: '$file'"
            return 1
        }

    return 0
}
