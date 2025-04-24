---
title: 'argNorm: Normalization of antibiotic resistance gene annotations to the Antibiotic Resistance Ontology (ARO)'
authors:
- Svetlana Ugarcina Perovic
- Vedanth Ramji
- Hui Chong
- Yiqian Duan
- Finlay Maguire
- Luis Pedro Coelho
short_description: 'Presenting argNorm, a command line tool and Python library to normalize antibiotic resistance gene annotations to the Antibiotic Resistance Ontology (ARO)'
journal: 'Bioinformatics'
doi: 10.1093/bioinformatics/btaf173
year: 2024
date: '2025-04-16'
---
Motivation: Currently available and frequently used tools for annotating antimicrobial resistance genes (ARGs) in genomes and metagenomes provide results using inconsistent nomenclature. This makes the comparison of different ARG annotation outputs challenging. The comparability of ARG annotation outputs can be improved by mapping gene names and their categories to a common controlled vocabulary such as the Antibiotic Resistance Ontology (ARO).

Results: We developed argNorm, a command line tool and Python library, to normalize all detected genes across 6 ARG annotation tools (8 databases) to the ARO. argNorm also adds information to the outputs using the same ARG categorization so that they are comparable across tools.

Availability and implementation: argNorm is available as an open-source tool at: https://github.com/BigDataBiology/argNorm. It can also be downloaded as a PyPI package and is available on Bioconda and as an nf-core module.
