---
title: "Global Microbial Small ORFs Catalog - Gene rarefaction for smORFs"
authors: "Breno Lívio Silva de Almeida, Celio Dias Santos Junior, Luis Pedro Coelho, Yiqian Duan"
date: 2022-09-29
---

**Abstract**: Having a dataset with around 1 billion unique smORFs, we generated rarefaction curves for different habitats, and also when grouping them in higher-level environments. 
The curves show that habitats such as soil remain relatively under-sampled and show higher smORFs richness compared to other environments.

## Distribution of the Small Open Reading Frames

There are millions of [open reading frames](https://en.wikipedia.org/wiki/Open_reading_frame) (ORFs) spread through the genomes from diverse habitats that, if they were translated, would generate many small proteins (those with fewer than 100 amino acids) - these would be the small ORFs (smORFs) [[1](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-020-03805-x), [2](https://elifesciences.org/articles/03528)].

For a clearer look at the distribution of smORFs throughout different environments, we can use methods such as the [rarefaction curve](https://www.biosym.uzh.ch/modules/models/Biodiversity/MeasuresOfBioDiversity.html), which is produced by repeatedly re-sampling the pool of N smORFs (in our case), at random, plotting the average number of smORFs represented by the corresponding number of samples. 
By visualizing the curves, we can infer if the sampling is saturating (_i.e._, whether additional sampling would be expected to significantly increase the set of known sequences).

Generating rarefaction curves can be a simple problem.
However, when dealing with large-scale data, we need to take into account high computational demands.
For this project, we dealt with almost 1 billion unique smORFs spread through the environments, making it unfeasible to just store them in the memory to find the counting of the unique ones.

## Data Processing

Our data consist of a set of samples.
Each sample produces a number of smORFs and is annotated with one or more habitat tags.

We built the following pipeline:

![figure1]({{ site.baseurl }}/assets/2022-09-29-smorfs_rarefaction/pipeline.svg)

For the table containing the relation of the smORFs to sample, a compressed file, we had 2.9 billion observations.
For this dataset, we had to preprocess it turning the smORFs annotations into integers by theirs unique IDs, and splitting the dataset into text files by samples, obtaining 63,402 files.
This script was run using [PyPy](https://www.pypy.org/), which uses a just-in-time compiler.

After the splitting step, for each habitat, we kept its samples in persistent storage using [Python's shelve](https://docs.python.org/3/library/shelve.html) [[3](https://www.python.org/downloads/release/python-382/)], making it computationally feasible to retrieve the smORFs from each sample.

As the rarefaction of different environments can be split into more than one task, we used the [Jug](https://jug.readthedocs.io/en/latest/) framework, which allows us to run the corresponding tasks on different processors [[4](https://openresearchsoftware.metajnl.com/articles/161/)].
The framework was applied when creating the database for each habitat, and when generating the permutations of the samplings.

One of the issues to consider when dealing with a large number of elements in Python is how to represent them. In [Python 3](https://docs.python.org/3/library/stdtypes.html) we can have integers with at least 24 bytes. To have in the memory 100 million smORFs, we would need to have at least 24 GB of memory.
Considering that, to represent the smORFs we used the [bitarray library](https://pypi.org/project/bitarray/), which provides an object type that efficiently represents an array of booleans.

For each permutation we had a bitarray object, and, as we add more samples with their corresponding smORFs, we indicate in it the smORFs already found with 1.
And for each number of samples considered, we summed all "True" values to find the unique counting of smORFs. We generated 24 permutations.

## Rarefaction Curves

With the permutations of the samplings generated, we took the average for each number of samples considered in the permutations.
Firstly, we only selected the ten habitats with the most samples for proper visualization.
We have the following rarefaction curve:

![figure2]({{ site.baseurl }}/assets/2022-09-29-smorfs_rarefaction/general_envs.svg)

In this case, habitats such as soil are still under-sampled, but we also have environments such as the human gut and built environment that can be seen as having lower smORFs richness, reaching diminishing returns per sample.

We can also group these habitats by higher-level environment names. Considering this, we have the following rarefaction curve:

![figure3]({{ site.baseurl }}/assets/2022-09-29-smorfs_rarefaction/high_envs.svg)

Considering the grouping made, we have a similar pattern of the rarefaction curve from before, with soil-related habitat under-sampled and human gut oversampled.

As expected, the rarefaction curves match curves in works such as [[5](https://www.nature.com/articles/s41586-021-04233-4)] made for unigenes, showing a similar tendency of over and under-sampling curves with the same habitats.

## Conclusions

Many methods for biological data analysis, such as rarefaction curves, have non-trivial costs for large datasets.
Along with running these methods, we need to find suitable ways to represent our data, making the generation of rarefaction curves computationally feasible.
With these optimizations made, we can work with larger datasets with fewer hardware requirements.

We can generate these curves considering multiple habitats, and they can be a great tool to visualize and compare the richness of an element such as smORFs in them.

---

[[1](https://bmcbioinformatics.biomedcentral.com/articles/10.1186/s12859-020-03805-x)] Ji, X., Cui, C., & Cui, Q. (2020). smORFunction: a tool for predicting functions of small open reading frames and microproteins. BMC bioinformatics, 21(1), 1-13.

[[2](https://elifesciences.org/articles/03528)] Aspden, J. L., Eyre-Walker, Y. C., Phillips, R. J., Amin, U., Mumtaz, M. A. S., Brocard, M., & Couso, J. P. (2014). Extensive translation of small open reading frames revealed by Poly-Ribo-Seq. elife, 3, e03528.

[[3](https://www.python.org/downloads/release/python-382/)] Van Rossum, G. (2020). The Python Library Reference, release 3.8.2. Python Software Foundation.

[[4](https://openresearchsoftware.metajnl.com/articles/161/)] Coelho, L. P. (2017). Jug: Software for parallel reproducible computation in python. Journal of Open Research Software, 5(1).

[[5](https://www.nature.com/articles/s41586-021-04233-4)] Coelho, L. P., Alves, R., Del Río, Á. R., Myers, P. N., Cantalapiedra, C. P., Giner-Lamia, J., ... & Bork, P. (2022). Towards the biogeography of prokaryotic genes. Nature, 601(7892), 252-256.
