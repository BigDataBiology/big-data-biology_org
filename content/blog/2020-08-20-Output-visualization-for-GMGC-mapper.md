---
title: "Output visualization for GMGC-mapper"
date: 2020-08-20
---

_Fernanda Ordoñez Jiménez_

<div style="padding: 1em" markdown="1">

</div>

GMGC-mapper is a command line tool that allows users to query the [Global Microbial Gene Catalog v1.0 (GMGC)](http://gmgc.embl.de), which combines metagenomics and high-quality sequenced isolates to form a catalog with 303 million unigenes.Given a genome (or any other set of genes), GMGC-mapper finds metagenomes where they (or similar sequences) are present. It can also identify MAGs (metagenome-assembled genomes) that are similar. 

In version 0.2, the [output consisted](https://gmgc-mapper.readthedocs.io/en/latest/output/) of the predicted gene sequences and the gene information, three tables and a readable summary of the results. The goal of my project was to improve it by giving the user basic graphic visualization of the data in the tables. I added visualizations in four categories:
  - A summary of the hits 
  - A map showing the locations and the habitats where the hits originated
  - The MAGs that are candidates
  - A cross-tabulation of the hit quality and habitat

To accomplish it, I use well-established libraries of the Python ecosystem like Pandas, NumPy and Matplotlib to visualize the tables data in a Jupyter notebook with just a few lines of code. The notebook also serves as a demonstration of the data structures, so the user can modify the visual outcome and perform further analyses in the same environment. 

##### Summary of hit quality
This graph represents the percent of the query that was clustered in the 4 categories shown below.
![Alt Text]({{ site.baseurl }}/assets/2020-08-20-Output-visualization-for-GMGC-mapper/align_cat1.gif)

##### Map and habitat information
In order to avoid non-standard dependencies on specialized geoviz libraries a background world image was used for the map plots, so the user can see the relationship between the habitat and the location of the samples where the hits were found.
![figure1]({{ site.baseurl }}/assets/2020-08-20-Output-visualization-for-GMGC-mapper/map.png)
![figure2]({{ site.baseurl }}/assets/2020-08-20-Output-visualization-for-GMGC-mapper/habitat.png)

##### MAGs
![Alt Text]({{ site.baseurl }}/assets/2020-08-20-Output-visualization-for-GMGC-mapper/gb1.gif)

##### Cross-tabulation of the hit quality and habitat
![Alt Text]({{ site.baseurl }}/assets/2020-08-20-Output-visualization-for-GMGC-mapper/al_cat_hab.gif)

##### Conclusion
This work has discussed how GMGC-mapper version 0.2 lacked a good story for exploratory graph visualization, and the benefit as visual beings of upgrading it. The objectives were to develop a tool for the user to perform exploratory analysis and display these graphically. Both objectives were met, as this project serves a dual purpose of showing the user some basic summary of their results and demonstrating how the output tables from GMGC-mapper can be used for further analyses. 

##### Acknowledgements 
Special thanks to Luis Pedro Coelho, PI of Big Data Biology Lab at Fudan University, and Michael D. L. Johnson, PhD., David A. Baltrus, PhD., and Jennifer Gardy, PhD for NSURP.

