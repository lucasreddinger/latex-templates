# Academic paper template

A reusable LaTeX template for a journal-style article **with an optional online
supplement**. It provides a configured preamble (fonts, citations,
cross-references, theorem and float setup), a title page, custom commands, and
supplement machinery, wrapped around a short example paper you replace with your
own content.

## Files

| File | Purpose |
|------|---------|
| `ms.tex` | The template: a short example paper you replace with your own. |
| `prompt.md` | A helper prompt for dropping a draft document into the template. |
| `../references.bib` | Shared bibliography (biblatex format) at the project root. Replace with yours. |

## Compiling

The bibliography uses **biblatex + biber**, so a single `pdflatex` pass is not
enough. `ms.tex` reaches the shared assets through relative paths
(`../figures/`, `../tables/`, `../references.bib`), so compile from this
`paper/` directory. Easiest:

```sh
latexmk -pdf ms
```

Or manually:

```sh
pdflatex ms
biber    ms
pdflatex ms
pdflatex ms
```

`lualatex`/`xelatex` work too (swap the engine in latexmk with `-lualatex`).

Tested with TeX Live 2025. The default font stack is **Cochineal** (free), so it
builds on any current TeX Live / MiKTeX out of the box. A commented Minion Pro
(commercial) stack is included for camera-ready builds where that font is
installed (see **Fonts**).

## Fonts

The "Font face packages" block near the top offers four interchangeable stacks;
exactly one is active:

1. **Cochineal** + Source Sans Pro + Inconsolata — **default** (free). A refined
   Crimson: a warm, old-style book serif close in character to Minion, with
   matching `newtxmath` math. Builds on any current TeX Live.
2. **Libertinus** serif + sans + mono — free, the whole family from one source
   (the most internally coherent stack). Math is `newtxmath` with letterforms
   matched to Libertine. *(commented out)*
3. **STIX Two** (Times-like) + Source Sans Pro + Inconsolata — free,
   Times-flavoured text with the widest math-symbol coverage of these stacks.
   *(commented out)*
4. **Minion Pro** + Source Sans Pro + Inconsolata — **commercial**; must be
   installed separately. The personal camera-ready stack. *(commented out)*

To switch, comment the active block and uncomment another. The
`%%arxiv-font%%` / `%%not-arxiv-font%%` tags are there if you script the swap:
the `%%arxiv-font%%` lines (Cochineal, free) stay active for an arXiv upload,
the `%%not-arxiv-font%%` lines (Minion Pro) for everything else. Otherwise
ignore them.

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
`\mybb{1}(d=2)`, selecting the free `DSSerif` font directly via `\usefont`. It
therefore renders identically under any of the four font stacks — nothing to
swap when you change stacks.

**Environments & structures:**
- `hypothesis` — a numbered, `cleveref`-referable theorem environment.
- A custom `enumerate` label style for **Step 1: / Step 2:** procedures.
- `table` via `threeparttable` + `booktabs` + the `d{i.j}` decimal-aligning
  column type (`dcolumn`), with `tablenotes`.
- `figure` with self-contained TikZ (plus commented examples for dropping in
  externally generated tables/figures).

**Online supplement** (delete the whole block if unused) — its own title page,
table of contents, smaller font (11pt), 1in margins (with a commented KOMA
DIV-based alternative), "Supplement page N" footer, reset page numbering,
`S.`-prefixed table/figure numbers, and the `\suppsection` / `\suppsubsection` /
`\suppsubsubsection` commands numbering as S.1, S.1.1, S.1.1.1.

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

- The default **Cochineal** stack (`cochineal`, `newtxmath`, `sourcesanspro`,
  `inconsolata`) is fully free and in a full TeX Live. The commented Minion Pro
  stack (`MinionPro`, `newtxmath`) is commercial and must be installed
  separately.
- The `\mybb` indicator glyph uses `DSSerif` (free; the files ship with TeX
  Live), loaded directly via `\usefont`, so it is independent of the active
  font stack.
- Other non-default packages, all free and in a full TeX Live: `biblatex-chicago`,
  `tabfigures`, `threeparttable`, `dcolumn`, `subfig`, `pgfplots`, `contour`,
  `adjustbox`. If `tabfigures` is missing, comment out its `\usepackage` line —
  it only governs lining vs. old-style digits.
