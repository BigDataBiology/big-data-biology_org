---
title: 'SemiBin: Incorporating information from reference genomes with semi-supervised
  deep learning leads to better metagenomic assembled genomes (MAGs)'
authors:
- Shaojun Pan
- Chengkai Zhu
- Xing-Ming Zhao
- Luis Pedro Coelho
short_description: 'SemiBin is a semi-supervised MAG builder'
journal: 'BioRXiv'
doi: 10.1101/2021.08.16.456517
year: 2021
date: 2021-08-16
---

Metagenomic binning is the step in building metagenome-assembled genomes (MAGs)
when sequences predicted to originate from the same genome are automatically
grouped together. The most widely-used methods for binning are
reference-independent, operating <jats:italic>de novo</jats:italic> and allow
the recovery of genomes from previously unsampled clades. However, they do not
leverage the knowledge in existing databases. Here, we propose SemiBin, an open
source tool that uses neural networks to implement a semi-supervised approach,
<jats:italic>i.e.</jats:italic> SemiBin exploits the information in reference
genomes, while retaining the capability of binning genomes that are outside the
reference dataset. SemiBin outperforms existing state-of-the-art binning
methods in simulated and real microbiome datasets across three different
environments (human gut, dog gut, and marine microbiomes). SemiBin returns more
high-quality bins with larger taxonomic diversity, including more distinct
genera and species. SemiBin is available as open source software at
[https://github.com/BigDataBiology/SemiBin/](https://github.com/BigDataBiology/SemiBin).

