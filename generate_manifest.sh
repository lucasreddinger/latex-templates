#!/usr/bin/env bash
#
# generate_manifest.sh — build MANIFEST.md linking each manuscript float
# (table/figure) to its number, caption, generating program, run log, and
# resultant asset file.
#
# For every manuscript .tex in paper/ (ms, supplement, ms_combined — whichever
# exist) it reads the compiled .aux for exact float numbers and captions, scans
# the source for each float's \input / \includegraphics asset(s), and matches
# each asset to the program in programs/ that generates it (plus that program's
# log in programs/logs/). Output is grouped under one heading per .tex file.
#
# Numbers and captions come from a LaTeX build, so each file is compiled with
# latexmk when its .aux is missing or older than the source (pass --no-build to
# reuse whatever .aux is already there).
#
# Requires: latexmk (unless --no-build), plus awk, grep, sed. No Python needed.

set -euo pipefail
shopt -s nullglob

# ---- Configuration ----------------------------------------------------------
PAPER_DIR=paper                 # manuscripts live here
PROGRAMS_DIR=programs           # analysis code
LOG_DIR=programs/logs           # per-program run logs
ASSET_DIRS=(tables figures)     # where \input/\includegraphics assets live
ASSET_EXTS=(tex pdf png jpg jpeg eps svg)  # extensions to probe when an asset ref omits one
OUT=MANIFEST.md                 # generated manifest (overwritten each run)
BUILD=1                         # 0 (or --no-build) reuses existing .aux files

# Manuscript basenames to document; only those present as paper/<name>.tex are used.
CANDIDATES=(ms supplement ms_combined)

# Program filename extensions to match against, and the stem transforms the
# asset->program matcher applies. Tune these to your project's conventions.
PROG_EXTS=(tex.jinja do R r py sh)
STRIP_PREFIXES=(table_ figure_ estimates_)
STRIP_SUFFIXES=(_mini _covar _slides _bgtasks _pooled _twostep _both \
                _6x6 _4x3 _cr0cd0 _minionpro _charter _sourcesanspro _sourcesans)

# ---- Arguments --------------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    --no-build) BUILD=0 ;;
    -h|--help)  sed -n '2,20p' "$0"; exit 0 ;;
    *) echo "Unknown argument: $arg (use --no-build)" >&2; exit 1 ;;
  esac
done

# Run from the project root (the directory this script lives in).
cd "$(dirname "$0")"

# ---- awk stage A: parse a .aux -> "type<TAB>number<TAB>caption" per float ---
read -r -d '' AWK_AUX <<'AWK' || true
function grp(s, i,   depth, out, c, n) {
  # s[i] is "{"; return the content of the balanced {...} group (math braces ok)
  depth = 0; out = ""; n = length(s)
  for (; i <= n; i++) {
    c = substr(s, i, 1)
    if (c == "{") { depth++; if (depth == 1) continue }
    else if (c == "}") { depth--; if (depth == 0) break }
    out = out c
  }
  return out
}
function clean(c) {
  sub(/^\\ignorespaces */, "", c)
  gsub(/\\ignorespaces */, "", c)
  gsub(/\\relax/, "", c)
  gsub(/\\nobreakspace */, " ", c)
  gsub(/~/, " ", c)
  gsub(/\\&/, "\\&", c); gsub(/\\%/, "%", c); gsub(/\\_/, "_", c)
  gsub(/\\#/, "#", c);  gsub(/\\\$/, "$", c)
  gsub(/  +/, " ", c); sub(/^ +/, "", c); sub(/ +$/, "", c)
  return c
}
/@writefile[{]lo[tf][}]/ {
  cl = index($0, "\\contentsline ")
  if (cl == 0) next
  rest = substr($0, cl)
  if (index(rest, "\\contentsline {table}")  == 1) type = "table"
  else if (index(rest, "\\contentsline {figure}") == 1) type = "figure"
  else next
  if (!match(rest, /\\numberline [{][^}]*[}]/)) next
  num = substr(rest, RSTART, RLENGTH)
  sub(/\\numberline [{]/, "", num); sub(/[}]$/, "", num)
  after = substr(rest, RSTART + RLENGTH)
  bp = index(after, "{")
  cap = (bp ? clean(grp(after, bp)) : "")
  printf "%s\t%s\t%s\n", type, num, cap
}
AWK

# ---- awk stage B: parse a .tex -> "type<TAB>asset;asset;..." per float ------
read -r -d '' AWK_TEX <<'AWK' || true
function strip_comment(line,   i, n, c, prev, out) {
  n = length(line); out = ""; prev = ""
  for (i = 1; i <= n; i++) {
    c = substr(line, i, 1)
    if (c == "%" && prev != "\\") break
    out = out c; prev = c
  }
  return out
}
function add_asset(a, f,   arr, i, n) {
  if (f == "") return a
  n = split(a, arr, ";")
  for (i = 1; i <= n; i++) if (arr[i] == f) return a
  return (a == "" ? f : a ";" f)
}
{
  line = strip_comment($0)
  if (intf == 0) {
    if (match(line, /\\begin[{](table|figure|table\*|figure\*|sidewaystable|sidewaysfigure)[}]/)) {
      env = substr(line, RSTART, RLENGTH); sub(/\\begin[{]/, "", env); sub(/[}]$/, "", env)
      ftype = (env ~ /table/ ? "table" : "figure"); fenv = env
      intf = 1; captioned = 0; assets = ""
    } else next
  }
  if (line ~ /\\caption[^a-zA-Z]/ || line ~ /\\caption$/) captioned = 1
  tmp = line
  while (match(tmp, /\\input[ ]*[{][^}]*[}]/)) {
    f = substr(tmp, RSTART, RLENGTH); sub(/\\input[ ]*[{]/, "", f); sub(/[}]$/, "", f)
    assets = add_asset(assets, f); tmp = substr(tmp, RSTART + RLENGTH)
  }
  tmp = line
  while (match(tmp, /\\includegraphics([ ]*\[[^]]*\])?[ ]*[{][^}]*[}]/)) {
    f = substr(tmp, RSTART, RLENGTH); sub(/.*[{]/, "", f); sub(/[}]$/, "", f)
    assets = add_asset(assets, f); tmp = substr(tmp, RSTART + RLENGTH)
  }
  if (index(line, "\\end{" fenv "}")) {
    # A float counts if it is captioned in the source OR pulls in an asset
    # (an \input'd table carries its \caption inside the asset file, so it has
    # no in-source caption but still produces an aux entry).
    if (captioned || assets != "") printf "%s\t%s\n", ftype, assets
    intf = 0
  }
}
AWK

# ---- asset -> program + log matcher -----------------------------------------
# Precompute program files once: only real generators (by extension), excluding
# build-artifact dirs. A basename->path map gives O(1) lookups; PROG_LIST scopes
# the content-grep fallback so it never scans data/binaries.
declare -A PROG_BYNAME=()
PROG_LIST=()
while IFS= read -r p; do
  [ -n "$p" ] || continue
  p=${p#./}
  PROG_LIST+=("$p")
  bn=$(basename "$p")
  [ -n "${PROG_BYNAME[$bn]:-}" ] || PROG_BYNAME[$bn]="$p"
done < <(find "$PROGRAMS_DIR" -type f \
           \( -name '*.do' -o -name '*.R' -o -name '*.r' -o -name '*.py' \
              -o -name '*.sh' -o -name '*.jinja' \) \
           -not -path '*/output/*' -not -path '*/logs/*' -not -path '*/temp/*' \
           2>/dev/null | sort)

prog_stem() {  # basename minus all trailing known extensions
  local b; b=$(basename "$1")
  b=${b%.jinja}; b=${b%.tex}; b=${b%.do}; b=${b%.R}; b=${b%.r}; b=${b%.py}; b=${b%.sh}
  printf '%s' "$b"
}

find_prog_named() {  # echo path of program file with basename == $1
  local hit="${PROG_BYNAME[$1]:-}"
  [ -n "$hit" ] && { printf '%s' "$hit"; return 0; }
  return 1
}

resolve_program() {  # $1 = asset filename as referenced; echo program path or ""
  local full stem ext s hit
  full=$(basename "$1")
  stem=$full
  stem=${stem%.tex}; stem=${stem%.pdf}; stem=${stem%.png}; stem=${stem%.jpg}
  stem=${stem%.jpeg}; stem=${stem%.eps}; stem=${stem%.svg}

  # 1. exact jinja template named after the asset (table_x.tex -> table_x.tex.jinja)
  hit=$(find_prog_named "${full}.jinja") && { printf '%s' "$hit"; return 0; }
  hit=$(find_prog_named "${stem}.tex.jinja") && { printf '%s' "$hit"; return 0; }
  # 2/3/4. program basename == stem (then progressively stripped stem) w/ a PROG_EXT
  s=$stem
  while :; do
    for ext in "${PROG_EXTS[@]}"; do
      hit=$(find_prog_named "${s}.${ext}") && { printf '%s' "$hit"; return 0; }
    done
    # strip one known trailing suffix and retry; stop when none applies
    local before=$s suf
    for suf in "${STRIP_SUFFIXES[@]}"; do s=${s%$suf}; done
    [ "$s" = "$before" ] && break
  done
  # 5. content-grep the prefix-stripped stem across the program files only
  local gstem=$stem pre
  for pre in "${STRIP_PREFIXES[@]}"; do gstem=${gstem#$pre}; done
  if [ -n "$gstem" ] && [ "$gstem" != "$stem" ] && [ "${#PROG_LIST[@]}" -gt 0 ]; then
    hit=$(grep -lIF "$gstem" "${PROG_LIST[@]}" 2>/dev/null | head -1 || true)
    [ -n "$hit" ] && { printf '%s' "$hit"; return 0; }
  fi
  return 1
}

resolve_log() {  # $1 = program path; echo log path or ""
  local stem; stem=$(prog_stem "$1")
  for ext in txt log; do
    [ -f "$LOG_DIR/$stem.$ext" ] && { printf '%s' "$LOG_DIR/$stem.$ext"; return 0; }
  done
  return 1
}

# ---- Emit one asset's detail line -------------------------------------------
asset_detail() {  # $1 = asset filename as referenced
  local a="$1" prog log apath d ext
  # locate the asset's real path under the asset dirs (probing extensions when
  # the reference omits one, as \includegraphics often does), for display.
  apath=""
  for d in "${ASSET_DIRS[@]}"; do
    if [ -f "$d/$a" ]; then apath="$d/$a"; break; fi
    for ext in "${ASSET_EXTS[@]}"; do
      [ -f "$d/$a.$ext" ] && { apath="$d/$a.$ext"; break 2; }
    done
  done
  [ -z "$apath" ] && apath="$a"
  prog=$(resolve_program "$a" || true)
  if [ -n "$prog" ]; then
    log=$(resolve_log "$prog" || true)
    printf 'program: `%s` · log: %s · asset: `%s`' \
      "$prog" "$([ -n "$log" ] && echo "\`$log\`" || echo "—")" "$apath"
  else
    printf 'program: _(no generator found)_ · log: — · asset: `%s`' "$apath"
  fi
}

# ---- Main -------------------------------------------------------------------
{
  echo "<!-- Generated by generate_manifest.sh — do not edit by hand. -->"
  echo "# Manifest"
} > "$OUT"

Tcap() { case "$1" in table) echo Table ;; figure) echo Figure ;; *) echo "$1" ;; esac; }

for f in "${CANDIDATES[@]}"; do
  tex="$PAPER_DIR/$f.tex"
  [ -f "$tex" ] || continue
  aux="$PAPER_DIR/$f.aux"

  if [ "$BUILD" = 1 ] && { [ ! -f "$aux" ] || [ "$tex" -nt "$aux" ]; }; then
    echo "Building $tex ..."
    blog=$(mktemp)
    if ! ( cd "$PAPER_DIR" && latexmk -pdf "$f" ) > "$blog" 2>&1; then
      echo "Warning: latexmk failed for $f; see $blog. Continuing with any existing aux." >&2
    else
      rm -f "$blog"
    fi
  fi
  [ -f "$aux" ] || { echo "Warning: no $aux; skipping $f." >&2; continue; }

  # Stage A + B
  mapfile -t AROWS < <(awk "$AWK_AUX" "$aux")
  mapfile -t BROWS < <(awk "$AWK_TEX" "$tex")

  na=${#AROWS[@]}; nb=${#BROWS[@]}
  if [ "$na" != "$nb" ]; then
    echo "Warning: $f: aux has $na captioned floats but source has $nb; numbers may be offset." >&2
  fi

  { echo ""; echo "## $f.tex"; } >> "$OUT"
  n=$(( na > nb ? na : nb ))
  [ "$n" = 0 ] && { echo "_(no tables or figures)_" >> "$OUT"; continue; }

  for ((k=0; k<n; k++)); do
    IFS=$'\t' read -r atype anum acap <<<"${AROWS[k]:-}"
    IFS=$'\t' read -r btype bassets <<<"${BROWS[k]:-}"
    type=${atype:-$btype}; num=${anum:-?}; cap=$acap
    # type sanity check
    if [ -n "${atype:-}" ] && [ -n "${btype:-}" ] && [ "$atype" != "$btype" ]; then
      num="?"
    fi
    label="**$(Tcap "$type") ${num}**"

    if [ -z "${bassets:-}" ]; then
      echo "- ${label} — ${cap} · _(inline, no external asset)_" >> "$OUT"
    else
      IFS=';' read -r -a arr <<<"$bassets"
      if [ "${#arr[@]}" = 1 ]; then
        echo "- ${label} — ${cap} · $(asset_detail "${arr[0]}")" >> "$OUT"
      else
        echo "- ${label} — ${cap}" >> "$OUT"
        for a in "${arr[@]}"; do echo "  - $(asset_detail "$a")" >> "$OUT"; done
      fi
    fi
  done
done

echo "Wrote $OUT"
