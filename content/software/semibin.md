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

The current version is **SemiBin 2.4.1** (released August 2026). This is a small
bugfix release: single-sample runs (`single_easy_bin` and
`generate_sequence_features_single`) now check upfront whether any input contig
is at least as long as the must-link threshold and, if not, abort immediately
with an informative message instead of failing later with an obscure error. See
the [ChangeLog](https://semibin.readthedocs.io/en/latest/whatsnew/) for the full
history.

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

