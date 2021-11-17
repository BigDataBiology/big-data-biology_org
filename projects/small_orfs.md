---
title: "Project Global smORFs - GMSC & AMPSphere"
short_description: "Project Global smORFs - GMSC & AMPSphere"
author_slugs:
- luis_pedro_coelho
---


# GMSC - Global Microbial Small ORFs Catalog

Small open reading frames(smORFs) are often ignored because of the minimal cutoff of 100 codons in
traditional gene annotation. However, recent studies indicated that small proteins produced by smORFs
serve as important functional elements in cellular biology, including the regulation of amino acid
metabolism, antimicrobial activity, etc. Due to computational and experimental difficulties, it still
remains a challenge to identify and characterize small proteins. The main limitation is lack of complete
and reliable smORFs database, especially in microbiome.Therefore, we constructed the global microbial
smORFs catalog(GMSC), which can provide a complete annotated resource in global microbiome across various
environments.

We predicted 4.5 billion smORFs from GMGCv2 and ProGenomes including tens of thousands metagenomes and
high-quality microbial genomes using a modified version of Prodigal. By eliminating redundancy and clustering,
we obtained smORFs catalog on 100%,90% and 50% sequence identity level. We excluded spurious smORFs using Antifam
and checked their coding potential using RNAcode. Then we used metatranscriptomics, metaproteomics and metariboseq
to validate.Finally, to characterize them, we assigned taxonomy and habitat to them based on metadata.

In 100% idntity smORFs catalog, 30% smORFs were predicted to coding potential and around 1% smORFs were validated
by multi-omics data, which contain at least 12 million smORFs. After assigning taxonomy using LCA, nearly 80% of
smORFs can be annotated on super kingdom level and nearly 40% of smORFs can be annotated on species level.

[Yiqian Duan](https://twitter.com/cocodyq) is a bioinformatician with expertise in high-throughput
sequencing to characterize environmental microbiomes. She is a Ph.D. candidate in
BDB since 2020, and is interested in the distribution, diversity and dynamics of small ORFs. Currently,
Yiqian and Dr. Celio Dias Santos Junior are conducting the investigations on the collaborative work
involving small ORFs.


# AMPSphere - the world wide survey for AMPs

![AMPSphere](/images/projects/small_orfs/ampsphere_logo.svg)

[AMPSphere](http://18.140.248.253:8080/home) (the world wide survey for AMPs)
is a initiative of BDB group with international collaboration (EMBL), aiming to
sample and catalog the antimicrobial peptides (AMPs) of prokaryotic origin from different environments.
The Big Data Biology Lab (BDB) via computational analyses of public metagenomes and isolate genomes
created the biggest and most-complete-to-date collection of AMPs, quantifying and qualifying their
presence in the environment. AMPs are small proteins (10-100 residues) that are able to disrupt microbial
growth. These molecules are used by different microbes to modulate their growth as colonies or even increase
their fitness in the inter- and intra-species competition. Currently, AMPs have a high potential to treat
persistent diseases, with some of them already being used as supplements or food addictives, e.g. nisin. 

**Our AMPSphere** is based on the outputs from our tool [Macrel](http://big-data-biology.org/software/macrel/)
(Metagenome AMPs Classification and Retrieval), where we catalogued about 1 million of AMPs, characterizing their
diversity available in publicly-available databases. From these peptides, some biological relevant questions popped up,
such as their origin. AMPs are codified by small genes that can be found sometimes inside regions that previously coded for
larger proteins. These cryptic peptides, or in short, cryptides are peptides that could be evolving from the disruption
of larger genes and directly impact microbial communities. To better understand the evolutionary and ecological mechanisms
that shape the global microbiome, we searched for the proteins that could be generated as cryptides.

[Dr. Celio Dias Santos Junior](https://twitter.com/celiodiasjunior) is a biotechnologist with expertise in high-throughput
sequencing, metagenomics and transcriptomics to characterize environmental microbiomes. He is a postdoctoral researcher in
BDB since 2019, and is interested in the distribution, diversity and dynamics of global antimicrobial peptides (work presented
at the [World Microbe Forum 2021](https://www.abstractsonline.com/pp8/#!/9286/presentation/7042)).

Celio has been mentoring undergraduate students developing side-projects related to our main research interests, 
including students signed within the [NSURP](https://nsurp.org/) (The National Summer Undergraduate Research Project) and 
[our BDB internship program](http://big-data-biology.org/positions/remote-internships/). 

[Amy Houseman](https://twitter.com/amyhouseman__/) developed a directed analysis of a cryptide candidate in human-associated
samples. It was called HG4 and was spotted in _Prevotella_ sp. distrupted genes. The fact that we could understand the evolutionary
history of that gene was remarkable. For more information see our [blogpost](https://big-data-biology.org/blog/2020/04/10/cryptic/).

[Tobi G. Olanipekun](https://twitter.com/tobi_olanipekun) developed the criterious analysis of features related to an AMP candidate
called AzuC, a gene that was previously described in _Escherichia coli_ and has so far no associated known function,
it is also available as a [post](https://big-data-biology.org/blog/2020/08/22/AzuC_A_non-conventional_AMP_candidate/).

More recently, [Anna Vines](https://twitter.com/annajovines) has showed a more holistic view on the cryptides, with a deep analysis
of the potential peptides matching high quality proteins databases. Her work showed that the global cryptome could be richer than
previously thought, check it out in the [link](https://big-data-biology.org/blog/2021/10/15/Cryptic_AMPs_from_prokaryotes/).

