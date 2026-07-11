# Programs

Analysis code for the project. Scripts here read the datasets in `../data/` and
write the generated figures and tables into `../figures/` and `../tables/`,
which `../paper/ms.tex` then `\input`s / `\includegraphics`.

Organize this however suits your toolchain (Stata `.do`, R, Python, …). A common
convention is a single entry point (e.g. `main.do` or a `Makefile`) that runs
the pipeline end to end, plus a note here on the order to run things and any
dependencies to install first.

## Reproducing

1. _Describe how to obtain / place the raw data in `../data/`._
2. _List the commands to run, in order._
3. _State the outputs written to `../figures/` and `../tables/`._
