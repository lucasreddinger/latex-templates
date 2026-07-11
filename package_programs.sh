#!/usr/bin/env bash
#
# package_programs.sh — bundle the analysis code in programs/ into a
# self-contained replication archive, ${PROJECT}_programs.zip.
#
# It copies programs/ into programs_package/, drops the build artifacts that a
# replicator regenerates (see EXCLUDES), optionally rewrites a local data path
# to a public download URL (see DATA_REWRITE_* below), and zips the result.
#
# Re-running refuses to clobber existing outputs; delete them first.
#
# Requires: zip, and GNU sed if you enable the data-path rewrite.

set -euo pipefail
shopt -s nullglob

# ---- Configuration ----------------------------------------------------------
PROJECT=project            # basename for the zip: ${PROJECT}_programs.zip
SRC=programs               # source directory to package

# Build artifacts to leave OUT of the package (names/paths under $SRC). The
# replicator regenerates these by running the code, so they don't get shipped.
EXCLUDES=(logs temp output)

# Optional: rewrite a local data path to a published download URL in the
# *packaged* copy, so a replicator pulls the public dataset. Leave both empty to
# skip. Example (the temptation project's Stata main.do -> OSF):
#   DATA_REWRITE_FILE=main.do
#   DATA_REWRITE_SED='s#local filename_data ".*"#local filename_data "https://osf.io/download/vftqn"#'
DATA_REWRITE_FILE=
DATA_REWRITE_SED=

# Run from the project root (the directory this script lives in).
cd "$(dirname "$0")"

# ---- Checks -----------------------------------------------------------------
if [ ! -d "$SRC" ]; then
    echo "Error: source directory '$SRC' not found." >&2
    exit 1
fi

pkg="${SRC}_package"
zipfile="${PROJECT}_programs.zip"
if [ -e "$pkg" ]; then
    echo "Error: '$pkg' already exists. Delete it and re-run." >&2
    exit 1
fi
if [ -e "$zipfile" ]; then
    echo "Error: '$zipfile' already exists. Delete it and re-run." >&2
    exit 1
fi

# ---- Assemble the package ---------------------------------------------------
echo "Copying $SRC/ into $pkg/ ..."
mkdir "$pkg"
cp -r "$SRC/." "$pkg/"

# Drop the regenerable build artifacts.
for e in "${EXCLUDES[@]}"; do
    if [ -e "$pkg/$e" ]; then
        echo "  excluding $e/"
        rm -rf "${pkg:?}/$e"
    fi
done

# ---- Optional: point the data path at the published dataset -----------------
if [ -n "$DATA_REWRITE_FILE" ] && [ -n "$DATA_REWRITE_SED" ]; then
    if [ -f "$pkg/$DATA_REWRITE_FILE" ]; then
        echo "Rewriting data path in $DATA_REWRITE_FILE ..."
        sed -i -E "$DATA_REWRITE_SED" "$pkg/$DATA_REWRITE_FILE"
    else
        echo "Warning: DATA_REWRITE_FILE '$DATA_REWRITE_FILE' not found in package." >&2
    fi
fi

# ---- Zip it up --------------------------------------------------------------
( cd "$pkg" && zip -rq "../$zipfile" . )
echo "Wrote $zipfile"
echo "Done."
