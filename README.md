# Academic paper and slides templates

A reusable LaTeX template for a journal-style article **with an optional online
supplement**. It provides a configured preamble (fonts, citations,
cross-references, theorem and float setup), a title page, custom commands, and
supplement machinery, wrapped around a short example paper you replace with your
own content. A matching beamer template for talks sits alongside it (see
**Slides**).

## Files

| File | Purpose |
|------|---------|
| `paper-template.tex` | The template: a short example paper you replace with your own. |
| `references.bib` | Example bibliography (biblatex format). Replace with yours. |
| `paper-template.pdf` | Rendered preview of the template as-is. |
| `slides-template.tex` | The slides template: a minimal example talk on the same paper. |
| `slides-template.pdf` | Rendered preview of the slides as-is. |
| `slides-palettes.tex` | Sample deck: one slide per slide color palette. |
| `slides-palettes.pdf` | Rendered sample deck, for comparing the palettes. |

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

`lualatex`/`xelatex` work too for the paper (swap the engine in latexmk with
`-lualatex`). The slides need pdflatex (see **Slides**).

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

## Slides

`slides-template.tex` is a minimal 16:9 beamer talk to go with the paper. It
does not reuse the paper's preamble: everything is sans-serif, and it loads
only what slides use.

```sh
latexmk -pdf slides-template.tex
```

**pdflatex only.** `lualatex` runs but falls back to Latin Modern, because the
sans-serif math (`mathastext`) needs Source Sans Pro's Type 1 fonts.

**Packages:** the `moloch` theme (the maintained fork of Metropolis);
`sourcesanspro` and `mathastext` for sans-serif text and math; and `booktabs`
for tables. Beamer itself supplies graphicx, xcolor, hyperref, and amsmath.
There is no bibliography machinery: cite by hand, as in "(Doe 2020)".

**Look:**
- Sans-serif throughout: text, math letters, Greek, and digits are all Source
  Sans Pro (the paper's sans).
- One rule, defined once as `\titlerule`: 0.4pt, in the accent color, the width of the
  text block, set 6pt below the title's baseline. It underlines the title on
  the title page, every frame, and every section divider, and frame titles
  start at the text margin, so titles, rules, and body text share one left
  edge. There are no progress bars; the footer's slide numbers show where the
  talk is. A dark standout frame closes the talk.
- Palettes work like the paper's font stacks: several blocks in
  **Configuration**, exactly one active (uncommented). Each sets five colors:
  `paper` (background), `ink` (text and titles), `accent` (title rules,
  bullets, block shading), `highlight` (`\alert`, also set bold), and
  `closing` (background of the closing "Thank you" slide). The default,
  palette 0, is **dark rules, vermilion alerts**: dark slate `#23373B` for
  text, rules, and bullets, vermilion `#D55E00` for alerts, and a charcoal
  `#333333` closing slide. Set aside for later, numbered 1–6 in order of
  preference: Paul Tol high-contrast, Monochrome + red, Nord, IBM Carbon,
  Solarized light, and Okabe–Ito (blue rules, vermilion alerts). `slides-palettes.pdf` has one
  sample slide per palette, with its closing-slide color in the bottom-right
  corner. Reuse the hex codes in R / Stata / Python figures so they match the
  slides.

**Features:**
- Overlays: `[<+->]` lists, `\pause`, and `\includegraphics<1>{...}` /
  `\includegraphics<2>{...}` to build a figure across clicks. Frames are
  top-aligned (`t`) so content doesn't jump as it appears.
- Handout mode: add `handout` to the class options for one page per frame.
- Speaker notes with `\note{...}`; uncomment the `show notes on second screen`
  line for a presenter tool such as pdfpc.
- Appendix slides after `\appendix`. The main talk's footer reads "n / N",
  with N counting the main talk only; appendix slides read "Appendix k / K".
  `\beamergotobutton` / `\beamerreturnbutton` link a main frame and its
  appendix frame.

**Slides checklist:**
1. Set the title, author, institute, and date in the **Metadata** block.
2. Replace the example frames; if you don't need the appendix, delete its
   block and the Robustness button on the results frame.
3. Put figures in `figures/`; `\input{tables/...}` generated tables.
4. To change colors, comment out the active palette block in
   **Configuration** and uncomment another (or add your own block). If you
   add or change a palette, add or change its `\showpalette` line in
   `slides-palettes.tex` so the sample deck stays complete.

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
- The slides use `moloch`, `sourcesanspro`, and `mathastext`; the placeholder
  images come from `mwe`. All are free and in a full TeX Live (tested with TeX
  Live 2025: moloch v0.6.0).
