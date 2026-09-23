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

The current version is **mahotas 1.4.19** (released September 22, 2026), the
first release in about two years. It requires Python 3.10 or later (supporting
up to Python 3.14 and NumPy 2.x) and replaces `setup.py` with a meson-python
build. It also fixes several correctness bugs, some of which change numerical
results, so please check your pipelines after upgrading: the RGB/XYZ/L\*a\*b\*
color conversions gave wrong values, `gbernsen()` had its local and global
thresholds swapped, `dog()` edges were shifted by one pixel, and `find()`
missed matches at the last row or column. `interpolate.shift()` and
`interpolate.zoom()` (and thus `features.lbp()`) now work on non-contiguous
arrays. The long-deprecated modules `mahotas.lbp`, `mahotas.surf`,
`mahotas.texture`, `mahotas.tas`, `mahotas.zernike`, and `mahotas.moments` have
been removed (use `mahotas.features.*` instead). See the
[ChangeLog](https://github.com/luispedro/mahotas/blob/main/ChangeLog) for the
full list of changes.

It is available on [PyPI](https://pypi.org/project/mahotas/) and
[conda-forge](https://anaconda.org/conda-forge/mahotas):

    pip install mahotas
    # or
    conda install -c conda-forge mahotas

## Mahotas links

- [Mahotas documentation](https://mahotas.readthedocs.io)
- Mahotas manuscript: [Mahotas: Open source software for scriptable computer vision](https://doi.org/10.5334/jors.ac) by [Luis Pedro Coelho](/person/luis_pedro_coelho) in _JORS_ 2013



