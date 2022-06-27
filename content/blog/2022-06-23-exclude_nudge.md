---
title: "If you are using RGI for your resistome study, you probably want --exclude_nudge"
authors: "Svetlana Ugarcina Perovic, Luis Pedro Coelho"
date: 2022-06-23
---

Many antibiotic resistome studies are based on CARD annotation hits mapped through the [RGI](https://github.com/arpcard/rgi) pipeline. This post will not be about the database but about a “feature” in the widely used tool RGI that can (and probably already has) affect your results resulting in a big number of “Perfect” and “Strict” hits.  

While annotating metagenomes from the [Global Microbial Gene Catalog](https://gmgc.embl.de/) through RGI with default (!) settings, we were happy to see a long list of antibiotic resistance genes (ARGs), mostly with “Strict” and “Perfect” hits. However, in one of the discussions with the [EMBARK](https://antimicrobialresistance.eu/) collaborators from the Forslund lab, we observed differences in BLAST (the default) and DIAMOND results. This observation has been already reported here https://github.com/arpcard/rgi/issues/147 but it was still surprising because we thought that if we were only including “Strict” hits, these two tools should be comparable as we expect the hits to be close to the query. After some digging, we realized that there is **a nudging heuristic that should be considered**. 
  
The RGI uses per-gene bitscore cut-offs (to detect functional homologs of ARGs) – superior to a general cut-off for all genes. However, if there is a high-identity match (95% amino acid identity), that bypasses the bitscore check – even results below the bitscore cutoff are considered “Strict”. However, there is no check for the length of the alignment. For example, even a 10 amino acid hit can be enough to “strictly detect” the following sequence as a beta-lactamase:

```
>CanThisBeABetaLactamase
MTHISISSURELYNOTABETALACTAMASEAAAGQQWQPSWKEAAAAAAA
```

it complains that O is not a real amino acid, but still calls it a beta lactamase, “Strict” hit. Basically, the GQQWQPSWKE motif matches exactly one of the genes in the database and this gets called a beta-lactamase.
 
This is when you run RGI offline with default (!) settings*: --alignment_tool BLAST AND “By default, all Loose RGI hits of 95% identity or better are automatically listed as “Strict”, regardless of alignment length, unless the --exclude_nudge flag is used.” That said, your “Loose” hit with at least 95 percent identity will be pushed into “Strict”.

![Fig1]({{ site.baseurl }}/assets/2022-06-23-exclude_nudge/exclude_nudge.png)

To overcome this very likely scenario of implausible results, you can disable this feature **--exclude_nudge** or filter out nudged results, **but the defaults are going to include them**. [**The GitHub Issue is open**](https://github.com/arpcard/rgi/issues/185) and we do hope that it will be solved and closed asap. In the meantime, keep in mind that BLASTP is much more sensitive than DIAMOND and finds these hits that should never have been reported (e-value > 1) and RGI default promotes them to “Strict”.

*interestingly, on the [webserver](https://card.mcmaster.ca/analyze/rgi) --exclude-nudge and --alignment_tool DIAMOND are the default parameters
