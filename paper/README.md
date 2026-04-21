# MoonAP v0.1 Paper Draft

This directory contains an English arXiv-style draft for MoonAP v0.1.

## Files

- `moonap-v0.1.tex`: main LaTeX source.
- `references.bib`: BibTeX references.
- `figures/`: screenshots copied from the project `imgs/` directory.
- `moonap-v0.1.pdf`: compiled PDF draft when generated locally.

## Build

From this directory, run:

```cmd
pdflatex moonap-v0.1.tex
bibtex moonap-v0.1
pdflatex moonap-v0.1.tex
pdflatex moonap-v0.1.tex
```

If `latexmk` is available:

```cmd
latexmk -pdf moonap-v0.1.tex
```

## Optional Extra Screenshots

The chat thread includes two additional screenshots showing Local/Cloud SKILL reuse and a FastQ report page. They are not yet local files in this repository. To include them later, save them as:

```text
paper/figures/screenshot-local-cloud-skill.png
paper/figures/screenshot-fastq-report.png
```

Then add corresponding `figure` blocks to `moonap-v0.1.tex`.
