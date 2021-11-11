---
title: 'Macrel: antimicrobial peptide screening in genomes and metagenomes'
short_description: 'Macrel is a tool for finding AMPs in (meta)genomes'
authors:
- "Célio Dias Santos Júnior"
- Shaojun Pan
- Xing-Ming Zhao
- Luis Pedro Coelho
journal: PeerJ
doi: 10.7717/peerj.10555
year: 2020
date: '2020-12-18'
---
## Motivation

Antimicrobial peptides (AMPs) have the potential to tackle multidrug-resistant
pathogens in both clinical and non-clinical contexts. The recent growth in the availability
of genomes and metagenomes provides an opportunity for in silico prediction of novel
AMP molecules. However, due to the small size of these peptides, standard gene prospection
methods cannot be applied in this domain and alternative approaches are necessary.
In particular, standard gene prediction methods have low precision for short peptides,
and functional classification by homology results in low recall.

## Results

Here, we present Macrel (for metagenomic AMP classification and retrieval),
which is an end-to-end pipeline for the prospection of high-quality AMP candidates
from (meta)genomes. For this, we introduce a novel set of 22 peptide features. These
were used to build classifiers which perform similarly to the state-of-the-art in
the prediction of both antimicrobial and hemolytic activity of peptides, but with
enhanced precision (using standard benchmarks as well as a stricter testing regime).
We demonstrate that Macrel recovers high-quality AMP candidates using realistic
simulations and real data.</jats:p>

## Availability

Macrel is implemented in Python 3. It is available as open source at
[https://github.com/BigDataBiology/macrel](https://github.com/BigDataBiology/macrel)
and through bioconda. Classification of peptides or prediction of AMPs in contigs
can also be performed on the webserver:
[https://big-data-biology.org/software/macrel](https://big-data-biology.org/software/macrel)
