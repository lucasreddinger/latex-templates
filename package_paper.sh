#!/usr/bin/env bash
#
# package_paper.sh — build the manuscript and bundle a self-contained arXiv
# upload.
#
# It compiles paper/ms.tex, drops a dated public copy of the PDF at the project
# root, then assembles paper_package/ (ms.tex + ms.bbl + everything in figures/
# and tables/) and zips it as ${PAPERNAME}_paper.zip for upload to arXiv.
#
# Fonts: if paper/ms.tex currently uses the commercial Minion Pro stack — i.e.
# an *uncommented* "%%not-arxiv-font%%" \usepackage line — the packaged copy is
# switched to the free arXiv stack (the "%%arxiv-font%%" lines) so the upload
# builds on arXiv. If a free stack is already active, the fonts are left alone.
# Your source file (paper/ms.tex) is never modified; only the copy in
# paper_package/ is rewritten.
#
# Re-running refuses to clobber existing outputs; delete them first.
#
# Requires: latexmk + biber, zip, and GNU sed/grep (Git Bash on Windows is fine).

set -euo pipefail
shopt -s nullglob

# ---- Configuration ----------------------------------------------------------
PAPERNAME=paper            # basename for the dated PDF and the arXiv zip
MAIN=ms                    # paper/<MAIN>.tex is the manuscript
DATE=$(date +"%Y-%m-%d")

# Run from the project root (the directory this script lives in).
cd "$(dirname "$0")"

# ---- Build ------------------------------------------------------------------
( cd paper && latexmk -pdf "$MAIN" )

# ---- Dated public copy of the PDF at the project root -----------------------
public_pdf="${PAPERNAME}_${DATE}.pdf"
if [ -e "$public_pdf" ]; then
    echo "Note: $public_pdf already exists; leaving it in place." >&2
else
    cp "paper/${MAIN}.pdf" "$public_pdf"
    echo "Wrote $public_pdf"
fi

# ---- Refuse to clobber an existing package ----------------------------------
pkg=paper_package
zipfile="${PAPERNAME}_paper.zip"
if [ -e "$pkg" ]; then
    echo "Error: '$pkg' already exists. Delete it and re-run." >&2
    exit 1
fi
if [ -e "$zipfile" ]; then
    echo "Error: '$zipfile' already exists. Delete it and re-run." >&2
    exit 1
fi

# ---- Assemble the package (flat: arXiv wants sources in one directory) ------
mkdir "$pkg"

cp "paper/${MAIN}.tex" "$pkg/"

# arXiv does not run biber, so ship the precompiled bibliography.
if [ -f "paper/${MAIN}.bbl" ]; then
    cp "paper/${MAIN}.bbl" "$pkg/"
else
    echo "Warning: paper/${MAIN}.bbl not found — arXiv needs it for the" \
         "bibliography. Did latexmk run biber?" >&2
fi

# Generated assets. Skeleton dirs may be empty; nullglob makes the globs vanish.
assets=(figures/*.pdf figures/*.tex tables/*.tex)
if (( ${#assets[@]} )); then
    cp "${assets[@]}" "$pkg/"
fi

# ---- Switch to the free font stack, only if Minion Pro is active ------------
# "Minion Pro is active" == there is an uncommented "%%not-arxiv-font%%"
# \usepackage line (a commented line starts with %, so it won't match).
if grep -Eq '^[[:space:]]*\\usepackage.*%%not-arxiv-font%%' "$pkg/${MAIN}.tex"; then
    echo "Minion Pro detected — switching the packaged copy to the free arXiv fonts."
    # comment the commercial (non-arXiv) lines ...
    sed -i -E 's/^([[:space:]]*)(\\usepackage.*%%not-arxiv-font%%)/\1%\2/' "$pkg/${MAIN}.tex"
    # ... and uncomment the free (arXiv) lines.
    sed -i -E 's/^([[:space:]]*)%(\\usepackage.*%%arxiv-font%%)/\1\2/' "$pkg/${MAIN}.tex"
else
    echo "A free font stack is already active — leaving the fonts unchanged."
fi

# ---- Zip it up --------------------------------------------------------------
( cd "$pkg" && zip -q "../$zipfile" ./* )
echo "Wrote $zipfile"
echo "Done. Upload $zipfile to arXiv."
