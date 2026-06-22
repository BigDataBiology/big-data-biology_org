---
title: argNorm
meta: Software tools developed by the BDB-Lab
---

argNorm is a tool to normalize antibiotic resistance genes (ARGs) by mapping them to the
[antibiotic resistance ontology (ARO)](https://obofoundry.org/ontology/aro.html) by CARD. It also provides drug categorization of drugs that antibiotic resistance genes confer resistance to.

Different ARG annotation tools report results using their own naming schemes,
which makes it hard to compare or combine outputs. argNorm solves this by
normalizing the outputs of many widely-used tools — including NCBI
AMRFinderPlus, CARD/RGI, ResFinder, ARG-ANNOT, DeepARG, MEGARes, SARG, and
GROOT — to a common ontology, and works directly with
[hAMRonization](https://github.com/pha4ge/hAMRonization)-formatted input.

## Latest release

The current version is **argNorm 1.1.0** (released June 2025), which improves
NCBI mappings (particularly for hAMRonized data) and fixes a number of edge
cases.

argNorm is available on [PyPI](https://pypi.org/project/argnorm/) and
[bioconda](https://anaconda.org/bioconda/argnorm):

    pip install argnorm
    # or
    conda install -c bioconda argnorm

## argNorm tutorial

<iframe width="560" height="315" src="https://www.youtube.com/embed/vx8MCQ7gDLs?si=cgnPrl-NODuh-LHR" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>


## argNorm links

- [argNorm documentation](https://argnorm.readthedocs.io/en/latest/)
- [argNorm Repository](https://github.com/BigDataBiology/argNorm/tree/main)
