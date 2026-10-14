---
title: SemiBin
meta: Software tools developed by the BDB-Lab
---

SemiBin is a metagenomic binning tool (MAG builder). It is based on deep
contrastive learning to incorporate background information (from reference
genomes).

It achieves better results than other tools across a range of microbial
habitats (both host-associated and environmental habitats).

SemiBin2 introduced self-supervised contrastive learning (removing the need
for the more expensive semi-supervised step) and added support for binning
long-read assemblies, making it both faster and more accurate than the
original version.

## Latest release

The current version is **SemiBin 2.6.0** (released October 14, 2026). It
raises the minimum requirements to Python 3.11, pandas 3, and PyTorch 2.4
(pixi and conda handle this for you; if you are stuck on Python 3.10 or
pandas 2, stay on SemiBin 2.5.0).

It adds shell tab completion of subcommands and options. To enable it in bash
or zsh, add this to your `~/.bashrc` (or `~/.zshrc`):

    eval "$(register-python-argcomplete SemiBin2)"

Static completion scripts for bash, zsh, fish, tcsh, and PowerShell can also
be generated, see the [installation
docs](https://semibin.readthedocs.io/en/latest/install/#shell-tab-completion).

Most of the bug fixes make SemiBin stop early with a clear message where it
previously failed late with an obscure error: `multi_easy_bin` now checks up
front that every sample has at least one contig long enough for the must-link
threshold, `bin_long` validates its arguments like `bin` does, and failures of
prodigal, bedtools, or hmmsearch now report the exit status, the input, and
the tool's own error output. Loading models saved by SemiBin2 versions before
2.2.0 works again with PyTorch 2.6 or newer, and crashes on small or
low-quality assemblies where no marker genes pass the filters are fixed. See
the [ChangeLog](https://semibin.readthedocs.io/en/latest/whatsnew/) for the
full list of changes.

SemiBin is available on [bioconda](https://anaconda.org/bioconda/semibin) and
[PyPI](https://pypi.org/project/SemiBin/). We recommend installing it with
[pixi](https://pixi.sh/), which can even run it without installing:

    pixi exec -c bioconda -c conda-forge -s semibin SemiBin2

Alternatively, with conda:

    conda install -c conda-forge -c bioconda semibin

## SemiBin links

- [SemiBin documentation](https://semibin.readthedocs.io/)
- [SemiBin Github repository](https://github.com/BigDataBiology/SemiBin)
- [SemiBin users mailing-list](https://groups.google.com/g/semibin-users)
- SemiBin1 manuscript: [Shaojun Pan](/person/Shaojun_Pan) et al. [A deep siamese neural network improves metagenome-assembled genomes in microbiome datasets across different environments](https://www.nature.com/articles/s41467-022-29843-y) in _Nature Communications_ 2022
- SemiBin2 manuscript: [Shaojun Pan](/person/Shaojun_Pan) et al. [SemiBin2: self-supervised contrastive learning leads to better MAGs for short- and long-read sequencing](https://doi.org/10.1093/bioinformatics/btad209) in _Bioinformatics_ 2023

