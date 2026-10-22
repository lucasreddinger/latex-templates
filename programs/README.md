# Programs

Analysis code for the project. Scripts here read the datasets in `../data/` and
write the generated figures and tables into `../figures/` and `../tables/`,
which `../paper/ms.tex` then `\input`s / `\includegraphics`.

Organize this however suits your toolchain (Stata `.do`, R, Python, …). A common
convention is a single entry point (e.g. `main.do` or a `Makefile`) that runs
the pipeline end to end, plus a note here on the order to run things and any
dependencies to install first.

## Naming convention

`../generate_manifest.sh` links each manuscript float to the program that makes
it by **matching filenames**: name a generator after the asset it produces, so
`table_regression.do` (or `table_regression.tex.jinja`) generates
`../tables/table_regression.tex`, and `figure_hist.do` generates
`../figures/figure_hist*.pdf` (trailing size/font suffixes like `_6x6`,
`_minionpro` are stripped when matching). Write each program's run log to
`logs/<program-name>.txt` (e.g. Stata `log using logs/table_regression.txt, text
replace`) and the manifest will pick it up. Assets with no matching program are
reported as `(no generator found)`.

## Reproducing

1. _Describe how to obtain / place the raw data in `../data/`._
2. _List the commands to run, in order._
3. _State the outputs written to `../figures/` and `../tables/`._
