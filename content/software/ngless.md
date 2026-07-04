---
title: NGLess
meta: Software tools developed by the BDB-Lab
---

NGLess is a domain-specific language for NGS (next-generation sequencing
data) processing.

By making the analysis pipeline explicit and version-controlled, NGLess aims
to produce reproducible results: scripts declare the exact version of the
language and of any reference databases used. NG-meta-profiler, a collection of
predefined pipelines built on NGLess, provides fast taxonomic and functional
profiling of metagenomes.

![NGLess cartoon](/images/NGLess-cartoon.svg)

## NGLess example

    ngless "1.0"
    input = fastq(['ctrl2.fq','ctrl2.fq','stim1.fq','stim2.fq'])
    input = preprocess(input) using |read|:
        read = read[5:]
        read = substrim(read, min_quality=26)
        if len(read) < 31:
            discard

    mapped = map(input, reference='hg19')
    write(count(mapped, features=['gene']),
            ofile='gene_counts.csv',
            format={csv})


## Latest release

The latest releases are **NGLess 1.6.0-beta2** (released July 4, 2026) and
**NGLess 1.6.0-beta1** (released July 1, 2026), the first betas of the upcoming
1.6.0 series. See the [changelog](https://ngless.readthedocs.io/en/latest/whatsnew.html#version-1-6-0)
for details.

The current stable version is **NGLess 1.5.0** (released September 2024), which
added YAML-based sample specification, new `run_for_all` functions for the
parallel module, and improved compression and file handling.

NGLess is available on [bioconda](https://anaconda.org/bioconda/ngless):

    conda install -c bioconda ngless

## NGLess links
- [NGLess documentation](https://ngless.embl.de)
- [NGLess Github repository](https://github.com/ngless-toolkit/ngless)
- NGLess manuscript: [NG-meta-profiler: fast processing of metagenomes using NGLess, a domain-specific language](https://doi.org/10.1186/s40168-019-0684-8) by [Luis Pedro Coelho](/person/luis_pedro_coelho), Renato Alves, Paulo Monteiro, Jaime Huerta-Cepas, Ana Teresa Freitas, Peer Bork in _Microbiome 2019_

