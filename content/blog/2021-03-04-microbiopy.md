---
layout: single
title: "Analysing microbiome count data using microbiopy"
date: 2021-03-04
---
_Karma Dolkar, Luis Pedro Coelho_

<div style="padding: 1em" markdown="1">

</div>


## Abstract

Microbiopy aims to become a tool that implements machine learning analysis on microbiome count data using Python. Currently, it implements basic functionality, which can already be used to perform some basic analyses as described here.


## The Microbiome

The microbiome is a collection of all microbes in an environment. Many different bacterial, fungal, and archaeal species constitute the microbial consortia. They can be found in a variety of environments, ranging from the human body (like the mouth, skin, gut), animal body, soil, glacier ice, seawater, or even walls or floors of homes.


## Microbiopy

Analysing microbiome samples can show microbiome patterns that help predict the characteristics of the host under consideration. Features include characteristics like weight (lean, overweight), age, sex, cohort, and similar attributes. Microbiopy does this by filtering features across samples based on minimum prevalence, minimum prevalence fraction, minimum average abundance, and minimum abundance fraction. Additionally, Microbiopy implements Principal Component Analysis on the data to show relationships in two dimensions.


## Analysis Functions

There are two functions that Microbiopy can currently perform:

- Filter Features
- Principal Component Analysis

**Filter Features** is a function that filters features across samples based on different criteria. The inputs are a sample by feature matrix and one or more of the following filtering criteria (in the following order):
- Minimum prevalence
- Minimum prevalence fraction
- Minimum average abundance
- Minimum abundance fraction

Prevalence is the proportion of samples containing a certain organism. Abundance is a measure of how commonly an organism occurs across samples.

[**Principal Component Analysis**](https://en.wikipedia.org/wiki/Principal_component_analysis#Details) is a dimension-reduction machine learning method, which can be used to show information along the components that carry the most of it. It helps improve interpretation of data. Before carrying out PCA, microbiopy will perform a [logarithmic transform of the data](https://en.wikipedia.org/wiki/Variance-stabilizing_transformation#Example:_relative_variance).

- **Data Preparation for PCA**

The input data is a sample by feature matrix. It is firstly converted to a numpy array. Next, a logarithmic transform is performed on it using the log_transfrom() function. 

- **PCA**

The do_pca() function carries out PCA on the log transformed input data.

- **Plotting PCA results**

The generate_pca() function generates a scatter plot of the PCA results.


## Results
After filtering the data based on prevalence and/or abundance and performing PCA on it, Microbiopy yields a two-dimensional visualization of the data.

![figure1]({{ site.baseurl }}/assets/2021-03-04-microbiopy/microbiopy.png)
<div class="caption"><b>Figure 1</b>:Sample PCA plots also available at the demo link provided below.</div>

## Conclusion
Microbiopy implements machine learning analysis on microbiome count data and serves as a proof of concept for utilising Python to achieve the same.


## Demonstration and Code
[Link to demo](https://mybinder.org/v2/gh/BigDataBiology/microbiopy_demo/9d19ea6d9047c8204f87112ede9822743fe174db?filepath=microbiopy_demo.ipynb)


[Link to code](https://github.com/BigDataBiology/microbiopy)
