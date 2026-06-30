# Academic paper template

A reusable LaTeX template for a journal-style article **with an optional online
supplement**. It provides a configured preamble (fonts, citations,
cross-references, theorem and float setup), a title page, custom commands, and
supplement machinery, wrapped around a short example paper you replace with your
own content.

## Files

| File | Purpose |
|------|---------|
| `paper-template.tex` | The template: a short example paper you replace with your own. |
| `references.bib` | Example bibliography (biblatex format). Replace with yours. |
| `paper-template.pdf` | Rendered preview of the template as-is. |

## Compiling

The bibliography uses **biblatex + biber**, so a single `pdflatex` pass is not
enough. Easiest:

```sh
latexmk -pdf paper-template.tex
```

Or manually:

```sh
pdflatex paper-template
biber    paper-template
pdflatex paper-template
pdflatex paper-template
```

`lualatex`/`xelatex` work too (swap the engine in latexmk with `-lualatex`).

Tested with TeX Live 2025. The default font stack is **Minion Pro** (commercial;
must be installed separately). If it is not installed, switch to the free Charter
stack (see **Fonts**) and it builds on any current TeX Live / MiKTeX.

## Fonts

The "Font face packages" block near the top offers three interchangeable stacks;
exactly one is active:

1. **Minion Pro** + Source Sans Pro + Inconsolata — **default**. Minion Pro is
   **commercial** and must be installed.
2. **Charter / XCharter** + Source Sans Pro + Inconsolata — 100%-free fallback
   (e.g. for arXiv or a machine without Minion Pro). *(commented out)*
3. **TeX Gyre Pagella** (Palatino) + TeX Gyre Heros + Inconsolata. *(commented out)*

To switch, comment the active block and uncomment another. The
`%%arxiv-font%%` / `%%not-arxiv-font%%` tags are there if you script the swap
(e.g. the free stack for arXiv, Minion Pro for camera-ready); otherwise ignore
them.

## What's included (feature reference)

**Title page** — sans-serif bold title, abstract, *JEL* codes, keywords, and
`\symfootnote{...}` for symbol-marked (`*`, `†`, …) acknowledgement and
affiliation notes that are counted separately from numbered footnotes.

**Citations** (`biblatex-chicago`, author-date):
- `\parencite{key}` → *(Doe 2020)*
- `\textcite{key}` → *Doe (2020)*
- `\citeauthor{key} (\citeyearlinked{key})` → *Doe (2020)* with only the year hyperlinked
- `\textcitedash{key}` → en-dashes co-authors, e.g. *Roe–Smith (2019)* (for "Murphy–Topel"-style method attributions)

**Cross-references** (`cleveref`): `\cref{...}` / `\Cref{...}` for sections,
equations, tables, figures, hypotheses, and supplement sections — all
hyperlinked, spelled out (no "fig.").

**Math** — `\mybb{1}` gives a blackboard-bold indicator digit, e.g.
`\mybb{1}(d=2)`, using Minion Pro's companion `dsserif` glyph. (A free-font
fallback using `dsfont` is kept in a comment.)

**Environments & structures:**
- `hypothesis` — a numbered, `cleveref`-referable theorem environment.
- A custom `enumerate` label style for **Step 1: / Step 2:** procedures.
- `table` via `threeparttable` + `booktabs` + the `d{i.j}` decimal-aligning
  column type (`dcolumn`), with `tablenotes`.
- `figure` with multi-panel `\subfloat` (`subfig`) and TikZ/pgfplots.

**Online supplement** (delete the whole block if unused) — its own title page,
table of contents, smaller font / wider margins, "Supplement page N" footer,
reset page numbering, `S.`-prefixed table/figure numbers, and the
`\suppsection` / `\suppsubsection` / `\suppsubsubsection` commands numbering as
S.1, S.1.1, S.1.1.1.

## Customization checklist

1. Set `\papertitle`, `\paperauthor`, `\paperdate` in the **Metadata** block.
2. Replace the example content (title-page notes, abstract, JEL, keywords, body, supplement).
3. Put your references in `references.bib`.
4. Point the **Paths** block (`\input@path`, `\graphicspath`) at your `tables/`
   and `figures/` folders, then `\input{...}` generated tables and
   `\includegraphics{...}` / `\input{...}` figures (commented examples are in
   the Results section).
5. Choose a font stack (see **Fonts**).

## Notes

- Default fonts use the commercial **Minion Pro** (`MinionPro`, `newtxmath`,
  `sourcesanspro`, `inconsolata`) plus `dsserif` for the indicator glyph. The
  free Charter fallback uses `XCharter` + `mathdesign` instead.
- Other non-default packages, all free and in a full TeX Live: `biblatex-chicago`,
  `tabfigures`, `threeparttable`, `dcolumn`, `subfig`, `pgfplots`, `contour`,
  `adjustbox`. If `tabfigures` is missing, comment out its `\usepackage` line —
  it only governs lining vs. old-style digits.
