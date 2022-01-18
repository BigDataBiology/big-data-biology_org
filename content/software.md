---
title: Software tools
meta: Software tools developed by the BDB-Lab
---


All our tools come with our [commitment to high quality scientific
software](/software/commitments).

# SemiBin

SemiBin is a metagenomic binning tool (MAG builder).

## SemiBin links

- [SemiBin Github repository](https://github.com/BigDataBiology/SemiBin)
- Preprint: [Shaojun Pan](/person/Shaojun_Pan) et al. [https://www.biorxiv.org/content/10.1101/2021.08.16.456517v1](https://www.biorxiv.org/content/10.1101/2021.08.16.456517v1)

# Macrel

[Macrel](/software/macrel/) (for metagenomic AMP classification and retrieval)
is an end-to-end pipeline for the prospection of high-quality AMP candidates
from (meta)genomes.

Its classifiers perform similarly to the state-of-the-art in the prediction of
both antimicrobial and hemolytic activity of peptides.  However, Macrel has a
enhanced precision, recovering high-quality AMP candidates using real data.

## Macrel links
- [Macrel webserver](/software/macrel/)
- [Macrel Github repository](https://github.com/BigDataBiology/macrel)
- Manuscript: [Santos-Júnior CD, Pan S, Zhao XM, Coelho LP. Macrel: antimicrobial peptide screening in genomes and metagenomes. PeerJ. 2020 Dec 18;8:e10555. doi: 10.7717/peerj.10555](https://doi.org/10.7717/peerj.10555)


# NGLess

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

# Jug

Jug is a *light-weight, Python only, distributed computing framework.*

Jug allows you to write code that is broken up into tasks and run
different tasks on different processors. You can also think of it as a
lightweight map-reduce type of system, although it\'s a bit more
flexible (and less scalable).

It has two storage backends: One uses the filesystem to communicate
between processes and works correctly over NFS, so you can coordinate
processes on different machines. The other uses a redis database and all
it needs is for different processes to be able to communicate with a
common redis server.

Jug is a pure Python implementation and should work on any platform.
Python 3 is supported (at least 3.3 and greater).

[Jug Documentation and Tutorial](https://jug.rtfd.org)

## Short Jug example

Here is a one minute example. Save the following to a file called
`primes.py`:

    from jug import TaskGenerator
    from time import sleep

    @TaskGenerator
    def is_prime(n):
        sleep(1.)
        for j in range(2,n-1):
            if (n % j) == 0:
                return False
        return True

    primes100 = map(is_prime, list(range(2,101)))

Of course, this is only for didactical purposes, normally you would use
a better method. Similarly, the `sleep` function is so that it does not
run too fast.

Now type `jug status primes.py` to get:

    Task name                    Waiting       Ready    Finished     Running
    ------------------------------------------------------------------------
    primes.is_prime                    0          99           0           0
    ........................................................................
    Total:                             0          99           0           0

This tells you that you have 99 tasks called `primes.is_prime` ready to
run. So run `jug execute primes.py &`. You can even run multiple
instances in the background (if you have multiple cores, for example).
After starting 4 instances and waiting a few seconds, you can check the
status again (with `jug status primes.py`):

    Task name                    Waiting       Ready    Finished     Running
    ------------------------------------------------------------------------
    primes.is_prime                    0          63          32           4
    ........................................................................
    Total:                             0          63          32           4

Now you have 32 tasks finished, 4 running, and 63 still ready.
Eventually, they will all finish and you can inspect the results with
`jug shell primes.py`. This will give you an `ipython` shell. The
[primes100]{.title-ref} variable is available, but it is an ugly list of
[jug.Task]{.title-ref} objects. To get the actual value, you call the
[value]{.title-ref} function:

    In [1]: primes100 = value(primes100)

    In [2]: primes100[:10]
    Out[2]: [True, True, False, True, False, True, False, False, False, True]

## Jug links

- [Jug documentation](https://jug.readthedocs.io)
- Jug Manuscript: [Jug: Software for parallel reproducible computation in Python](https://doi.org/10.5334/jors.161) by [Luis Pedro Coelho](/person/luis_pedro_coelho) in _JORS_ 2017

