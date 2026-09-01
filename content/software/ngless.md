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

    ngless "1.6"
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

The current version is **NGLess 1.6.0** (released August 4, 2026).

Starting with this version, NGLess is written in Rust: versions up to 1.5 were
written in Haskell and 1.6 replaces that implementation entirely. The motivation
was to simplify building, installing, and contributing to NGLess, rather than to
change what it does. NGLess 1.6 is intended as a compatible replacement for 1.5:
the same scripts should produce the same results (if you hit a discrepancy,
please [report it](https://github.com/ngless-toolkit/ngless/issues) &mdash;
output differences are treated as bugs).

Highlights of the release:

- The HTML run report is now a single self-contained `index.html` that embeds
  its own data and makes no network requests, so it works offline on compute
  clusters (the 1.5 report loaded AngularJS, jQuery, Bootstrap, and d3 from
  CDNs).
- Inline scripts (`-e`/`--script`) no longer write a report directory by
  default, as a throwaway one-liner rarely wants one. Pass `--create-report`
  (or `-o`) to force it. Running a script from a file is unchanged.
- `write()` now writes output files atomically, so a failed run no longer
  leaves a half-written file behind.
- Functions taking an output file check the output directory before the script
  runs, even when the file name is only computed at run time, so a missing
  output directory is reported immediately instead of after mapping or assembly
  has already run.
- `write()` and `collect()` support `auto_comments=[{date}]`, and `write()`
  gained the `{always_3_fq_files}` format flag.
- Better suggestions for mistyped arguments and flags.
- When an import of a local module cannot be found, the error lists every
  location that was searched, and any other versions of the module available.

See the [changelog](https://ngless.readthedocs.io/en/latest/whatsnew.html#version-1-6-0)
for the complete list.

### Upgrading from 1.5

NGLess 1.6 supports a single language version, so scripts must declare

    ngless "1.6"

at the top; declaring `"1.5"` or older is now an error. The built-in modules
(`parallel`, `samtools`, `mocat`, ...) also track the version, so import them at
version `"1.6"`; older module versions still work, with the latest behaviour,
but print a deprecation warning.

Three previously deprecated items were removed: the `strand` argument to
`count()` (use `sense`, with `{both}`/`{sense}`/`{antisense}`; `strand=True` is
equivalent to `sense={sense}`), the `--search-dir` command-line flag (use
`--search-path`), and the `--check-deprecation` flag, which was never
implemented. In practice, updating the version statement is the only change most
scripts need.

## Installation

NGLess is available on [bioconda](https://anaconda.org/bioconda/ngless):

    conda install -c bioconda ngless

Alternatively, [pixi](https://pixi.sh) will install NGLess into a
self-contained, per-project environment. Create a directory with a `pixi.toml`
containing

    [workspace]
    channels = ["conda-forge", "https://conda.anaconda.org/bioconda"]
    name = "ngless_env"
    platforms = ["linux-64"]
    version = "0.1.0"

    [dependencies]
    ngless = ">=1.6.0,<2"

and then run `pixi install`. The external tools that NGLess drives (bwa,
samtools, minimap2, megahit, prodigal) are dependencies of the conda package, so
they are installed for you in both cases.

## NGLess links
- [NGLess documentation](https://ngless.readthedocs.io/en/latest/)
- [NGLess Github repository](https://github.com/ngless-toolkit/ngless)
- NGLess manuscript: [NG-meta-profiler: fast processing of metagenomes using NGLess, a domain-specific language](https://doi.org/10.1186/s40168-019-0684-8) by [Luis Pedro Coelho](/person/luis_pedro_coelho), Renato Alves, Paulo Monteiro, Jaime Huerta-Cepas, Ana Teresa Freitas, Peer Bork in _Microbiome 2019_

