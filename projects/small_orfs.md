---
title: "Small Proteins of the Global Microbiome"
short_description: "Prospection for small ORFs of prokaryotic origin in the global microbiome"
author_slugs:
- celio_dias_santos_junior
- Yiqian_Duan
---

Small proteins (or small open reading frames, smORFs) are often ignored
computationally because of the technical difficulties they present, even though
recent studies indicated that small proteins have important functions in
cellular biology, such as the regulation of amino acid metabolism and
antimicrobial activity.

At the BDB-Lab, we have several sub-projects attempting to understand the role
they play in prokaryotic biology. One particular subset of small proteins that
we started to investigate are AMPs (anti-microbial peptides). These molecules
are used by different microbes to modulate their growth as colonies or even
increase their fitness in the inter- and intra-species competition. Currently,
AMPs have a high potential to treat persistent diseases, with some of them
already being used as supplements or food additives (_e.g._,
[nisin](https://en.wikipedia.org/wiki/Nisin)).

## Macrel

The recent growth in the availability of genomes and metagenomes provides an
opportunity for in silico prediction of novel AMP molecules. However, AMPs are
too small for standard gene prospection methods.

Macrel (for metagenomic AMP classification and retrieval) is an end-to-end
pipeline for the prospection of high-quality AMP candidates from (meta)genomes.
Its classifiers perform similarly to the state-of-the-art in the prediction of
both antimicrobial and hemolytic activity of peptides.  However, Macrel has
enhanced precision, recovering high-quality AMP candidates using real data.

Macrel is implemented in Python and is available as open source.

### Macrel Links
- [Macrel webserver](/software/macrel/)
- [Macrel repository](https://github.com/BigDataBiology/macrel)
- Manuscript: [Santos-Júnior CD, Pan S, Zhao XM, Coelho LP. Macrel: antimicrobial peptide screening in genomes and metagenomes. PeerJ. 2020 Dec 18;8:e10555. doi: 10.7717/peerj.10555. PMID: 33384902; PMCID: PMC7751412.](https://pubmed.ncbi.nlm.nih.gov/33384902/)


## AMPSphere - the world wide survey for AMPs

<div style="float: right; padding-left: 2em; width: 62%">
    <img src="/images/projects/small_orfs/ampsphere_fluxogram.png" alt="AMPSphere fluxogram" style="width: 100%" />
</div>

AMPSphere (the world wide survey for AMPs) aims to sample and catalog the
antimicrobial peptides (AMPs) of the global microbiome. AMPs are operationally
defined as proteins containing 10-100 residues, that are predicted to disrupt microbial
growth. Applying [macrel](/software/macrel) to metagenomes and isolate genomes,
and eliminating redundancy, we obtained a catalog of _ca._ 1 million AMPs.

We are currently attempting to better understand the evolutionary origin of
these genes. One route for the creation of smORFs is that they derive from
larger genes, which were disrupted forming smaller proteins, becoming
independent biological entities.

This project is conducted in collaboration with the [Bork Group at
EMBL](https://www.embl.org/groups/bork/) and the [Huerta-Cepas group at
CPGB](http://compgenomics.org/).

Working directly on the AMPs, [Dr. Celio Dias Santos Junior](https://twitter.com/celiodiasjunior), a biotechnologist with
expertise in high-throughput sequencing, metagenomics and transcriptomics to characterize environmental microbiomes.
He is a postdoctoral researcher in BDB since 2019, and is interested in the distribution, diversity and dynamics
of global antimicrobial peptides (work presented at the 
[World Microbe Forum 2021](https://www.abstractsonline.com/pp8/#!/9286/presentation/7042)).

Celio has been mentoring undergraduate students developing side-projects related to BDB main research interests, 
including students signed within the [NSURP](https://nsurp.org/) (The National Summer Undergraduate Research Project) and 
[our BDB internship program](/positions/remote-internships/). 

### AMPSphere Links

- [Permalink to the AMPSphere resource](https://zenodo.org/record/4606582)
- AMPSphere resource website:
- [http://ampsphere.big-data-biology.org/](http://ampsphere.big-data-biology.org/)
  (currently still a _WIP_)

## GMSC - Global Microbial Small ORFs Catalog

While the AMPSphere focuses on AMPs, whose function can be predicted with some
confidence, that still ignores the vast majority of smORFs. Therefore, we are
constructing a global microbial smORFs catalog (GMSC, by analogy with the
[GMGC](/projects/gmgc)), which will provide a complete annotated resource for
smORFs in the global microbiome.

So far, we predicted 4.5 billion smORFs and clustered them at 100%, 90%, and
50% amino acid sequence identity. A current focus is to further filter these
large datasets to obtain a high-quality subset.

[Yiqian Duan](https://twitter.com/cocodyq) is a bioinformatician with expertise in high-throughput
sequencing to characterize environmental microbiomes. She is a Ph.D. candidate in
BDB since 2020, and is interested in the distribution, diversity and dynamics of small ORFs. Currently,
Yiqian and Dr. Celio Dias Santos Junior are conducting the investigations on the collaborative work
involving small ORFs.

This project is conducted in collaboration with the
[Bork Group at EMBL](https://www.embl.org/groups/bork/) and the
[Huerta-Cepas group at CPGB](http://compgenomics.org/).

## Side Projects 

[Amy Houseman](https://twitter.com/amyhouseman__/) [developed a directed analysis of a cryptic peptide candidate in human-associated samples](https://big-data-biology.org/blog/2020/04/10/cryptic/).
It was called HG4 and was found in _Prevotella_ This was the initial hint for us that this could be an important mechanism.

More recently, [Anna Vines](https://twitter.com/annajovines) has showed us [a more holistic view on the cryptides](https://big-data-biology.org/blog/2021/10/15/Cryptic_AMPs_from_prokaryotes/) by searching for matches to the AMPSphere on the whole of [progenomes2](https://progenomes.embl.de/).

[Tobi G. Olanipekun](https://twitter.com/tobi_olanipekun) analyzed an AMP candidate called AzuC, a gene that was previously described in _Escherichia coli_ and has so far no associated known function. His work is described in [a blogpost](https://big-data-biology.org/blog/2020/08/22/AzuC_A_non-conventional_AMP_candidate/).

