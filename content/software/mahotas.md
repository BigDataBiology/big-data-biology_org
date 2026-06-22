---
title: Mahotas
meta: Software tools developed by the BDB-Lab
---

Mahotas is a Python computer vision and image processing library. It includes
many standard functions for image processing and feature computation and can be
used to implement the approaches described in [Coelho et al.,
2013](https://academic.oup.com/bioinformatics/article/29/18/2343/240179).

[mahotas-imread](https://imread.readthedocs.io/) is spin-off project which includes code to read/write images to files

Mahotas is written in C++ for speed and exposed to Python through a NumPy-based
interface. It includes implementations of watershed, convex points
computations, Haralick and Zernike texture features, local binary patterns,
thresholding, convolution, morphological operators, and more.

## Latest release

The current version is **mahotas 1.4.18** (released July 2024), which fixed a
bug in Haralick features and added compatibility with NumPy 2. Mahotas is a
mature, stable project supporting Python 3.6+ (as well as legacy Python 2.7).

It is available on [PyPI](https://pypi.org/project/mahotas/) and
[conda-forge](https://anaconda.org/conda-forge/mahotas):

    pip install mahotas
    # or
    conda install -c conda-forge mahotas

## Mahotas links

- [Mahotas documentation](https://mahotas.readthedocs.io)
- Mahotas manuscript: [Mahotas: Open source software for scriptable computer vision](http://doi.org/10.5334/jors.ac) by [Luis Pedro Coelho](/person/luis_pedro_coelho) in _JORS_ 2013



