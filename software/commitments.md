---
title: Big Data Biology Lab Software Tool Commitments
permalink: software/commitments/
meta: Tools
---

# Software tools commitments

**Preamble**. We produced two types of code artefacts: **(i)** code that is
supportive of results in a results-driven paper and **(ii)** software tools
intended for widespread use.

For an example, of the first type, see the [Code Ocean
capsule](https://codeocean.com/2018/04/04/similarity-of-the-dog-and-human-gut-microbiomes-in-gene-content-and-response-to-diet)
that is linked to [*(Coelho et al.,
2018)*](https://microbiomejournal.biomedcentral.com/articles/10.1186/s40168-018-0450-3).
The main goal of this type of code release is to serve as an _Extended
Methods_ section to the paper. Hopefully, it will be useful for the
small minority of readers of the paper who really want to dig into the
methods or build upon the results, but the work aims at biological
results.

This document refers to the second type of code release: tools that are
intended for widespread use. Here, we’ve released a few in the last few
years:
[*Jug*](https://openresearchsoftware.metajnl.com/articles/10.5334/jors.161/),
[*NGLess*](https://microbiomejournal.biomedcentral.com/articles/10.1186/s40168-019-0684-8),
and
[*Macrel*](https://www.biorxiv.org/content/10.1101/2019.12.17.880385v2).
Here, the whole point is that others use the code. We also use these
tools internally, but if nobody else ever adopts the tools, we will have
fallen short.

## The Six Commitments

1.  **Five-year support (from date of publication)** If we publish a tool as a
    paper, then we commit to supporting it for *at least five years* from the
    date of publication.

    We may stop developing new features, but if there are bugs in the
    released version, we will assume responsibility to fix them. We will
    also do any minor updates to keep the tool running (for example, if a
    new Python version breaks something in one of our Python-based tools, we
    will fix it).

    Typically, support is provided if you open an issue on the respective
    Github page and/or post to the respective mailing-list.

2.  **Standard, easy to install, packages**

    Right now, this means: *we provide conda packages*. In the future, if
    the community moves to another system, we may move too.

3.  **High-quality code with continuous integration** All our published
    packages have continuous integration and try to follow best practices in
    coding.

4.  **Complete documentation** We provide documentation for the tools,
    including tutorials, example data, and reference manuals.

5.  **Work well, fail well** We strive to make our tools not only work well,
    but also “fail well”: that is, when the user provides erroneous input, we
    attempt to provide good quality error messages and to never produce bad
    output (including never producing partial outputs if the process terminates
    part-way through processing).

6.  **Open source, open communication** Not only do we provide the released
    versions of our tools as open source, but all the development is done in
    the open as well.

***Note for group members***: This is a commitment from the group and,
at the end of the day, the responsibility is Luis’ responsibility. If
you leave the group, you don’t have to be responsible for 5 years. If
you leave, your responsibility is just the basic responsibility of any
author: to be responsive to queries about what was described in the
manuscript, but not anything beyond that. What it does mean is that we
will not be submitting papers on tools that risk being difficult to
maintain. In fact, while the goals above are phrased as outside-focused,
they are also important for internally being robust to group members
moving on.
