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
| `slides-template.tex` | The slides template: a short example talk on the same paper. |
| `slides-template.pdf` | Rendered preview of the slides as-is. |

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

`slides-template.tex` is a 16:9 beamer talk to go with the paper. Its preamble
keeps the paper's block structure (scaffolding vs. custom slots, so `prompt.md`
applies), citation setup, custom commands, paths, and metadata names, so text,
equations, hypotheses, and tables can be pasted between the two files.

```sh
latexmk -pdf slides-template.tex
```

**pdflatex only.** `lualatex` runs but falls back to Latin Modern, because the
sans-serif math setup (`mathastext`) needs Source Sans Pro's Type 1 fonts.

**Shared with the paper:** `biblatex-chicago` author-date citations, including
`\citeyearlinked` and `\textcitedash`; `\cref`; `\mybb`; the `d{i.j}` column
type with `threeparttable` and `booktabs`; the `hypothesis` environment; the
`tables/`, `figures/`, and `references.bib` paths; and the `\papertitle` /
`\paperauthor` metadata names.

**Different on slides:**
- One font stack: text *and* math in Source Sans Pro, the paper's sans.
  `mathastext` takes math letters, Greek, and digits from the body font, so
  decimal-aligned table numbers are sans too; `newtxmath` supplies the symbols.
  The paper's four stacks and `%%arxiv-font%%` tags are dropped, since slides
  don't go to arXiv.
- `hypothesis` uses beamer's own theorem machinery (a numbered block) instead
  of `ntheorem`.
- **Step 1:** labels use beamer's enumerate syntax, `[\bfseries Step 1:]`,
  instead of `enumitem`, which breaks beamer lists.
- `\cref` prints the right text but no hyperlink. Beamer loads hyperref with
  `implicit=false` (its own `\ref` is unlinked too), so cleveref logs a warning
  that it cannot add links. Citations are linked as usual.
- No `\symfootnote` or supplement machinery; backup slides take the
  supplement's role.

**Slide features:**
- The Moloch theme (the maintained fork of Metropolis), restyled light: frame
  titles on the page background above a thin progress rule, section divider
  slides, and a dark standout frame for the closing slide.
- A colorblind-safe Okabe–Ito palette, defined once: `ink` (`#23373B`, text),
  `accent` (blue `#0072B2`, structure), and `highlight` (vermilion `#D55E00`,
  `\alert`, also set bold). Use the same names in TikZ, or the same hex codes in
  R / Stata / Python, to match figures to the slides.
- Overlays: `[<+->]` lists, `\pause`, and `\only<2>{...}` inside TikZ. Frames
  are top-aligned (`t`) so content doesn't jump as it appears.
- Handout mode: add `handout` to the class options for one page per frame.
- Speaker notes with `\note{...}`; uncomment the `show notes on second screen`
  line for a presenter tool such as pdfpc.
- Backup slides after `\appendix`, kept out of the footer's total (the "n / N"
  counter counts the main talk only), with `\beamergotobutton` /
  `\beamerreturnbutton` links between a main frame and its backup.
- A closing slide with the paper link, a QR code (`qrcode`), and email, then a
  references frame that continues across pages if needed.

**Slides checklist:**
1. Set the **Metadata** block: `\papertitle` and `\paperauthor` (paste from the
   paper), `\paperurl`, `\talkvenue`, `\talkdate`, and `\institute`.
2. Replace the example frames; delete the backup block if you don't need it.
3. Drop in generated tables and figures with the commented examples after the
   figure frame (pgfplots figures need `\usepackage{pgfplots}`).
4. To rebrand, change the three palette colors in **Boilerplate
   configuration**.

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
- The slides also use `moloch`, `mathastext`, and `qrcode`, all free and in a
  full TeX Live (tested with TeX Live 2025: moloch v0.6.0).
