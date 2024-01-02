---
title: NGLess
meta: Software tools developed by the BDB-Lab
---

NGLess is a domain-specific language for NGS (next-generation sequencing
data) processing.

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


## NGLess links
- [NGLess documentation](https://ngless.embl.de)
- [NGLess Github repository](https://github.com/ngless-toolkit/ngless)
- NGLess manuscript: [NG-meta-profiler: fast processing of metagenomes using NGLess, a domain-specific language](https://doi.org/10.1186/s40168-019-0684-8) by [Luis Pedro Coelho](/person/luis_pedro_coelho), Renato Alves, Paulo Monteiro, Jaime Huerta-Cepas, Ana Teresa Freitas, Peer Bork in _Microbiome 2019_

