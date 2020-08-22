---
layout: single
title: "AzuC: A non-conventional AMP candidate"
date: 2020-08-22
---
<style>
div.caption {
    font-size: small;
    color: #333333;
    padding-bottom:1em;
    padding-left:1em;
    padding-right:1em;
    padding-top:0em;
}
</style>

_Tobi Olanipekun, Celio Dias Santos Junior and Luis Pedro Coelho_

<div style="padding: 1em" markdown="1">
<p><strong>Abstract: </strong> Potential AMP sequences were retrieved when using Macrel tool (DOI: 10.1101/2019.12.17.880385v4) to screen hundreds of publicly available metagenomes, some of these sequences were homologous to azuC, a protein without a known biological function, asides from its gene responding linearly to stress conditions like pressure and low Ph. AzuC was predicted as a potential AMP, thus this study aimed at investigating and analyzing this peptide for antimicrobial features by a series of in silico tests. Our results show azuC peptide as a typical antimicrobial peptide, in terms of structure and charges distribution, and it was predicted to be active against <em>K.pneumoniae</em> and <em>B.subtilis</em>. However, differently from other peptides no signal peptide was found, indicating that secretion should not be carried out. Therefore suggesting that azuC might have evolved from sequences with AMP functions, still retaining AMP properties, like its ability to interact with and modulate membranes. All these help us to conclude that asides killing microorganisms, AMPs can evolve into other functions.</p>


<h2>Quick recap on cryptic AMPs</h2>
<P>Our previous post about the peptide (HG4), found when searching for AMPs in human gut metagenome data, suggested that genes originally involved in other functions could become AMP genes via disruptive mutations. Moreover, tests carried out in silico showed the protease cleavage sites could release HG4 in human guts and it would have a half-life long enough for it to be active.  Now, we will talk about a novel class of AMP genes, the small unknown function proteins.</P>

<h2>Another potential AMPs</h2>
<P>In a similar work to the above, we used <a href="https://github.com/BigDataBiology/macrel">MACREL tool</a> to predict potential AMPs in hundreds of publicly available metagenomes. When cataloging these peptides, some of them were homologous to AzuC, a protein of unknown function,telling us that AzuC could be an AMP. While we are still awaiting further confirmatory work, this is a tempting hypothesis.</P>
<p>AzuC, despite its gene being largely documented, has remained with an unknown biological function.This is due to its small size which makes purification and characterization difficult. Recently, Guyet et al. (2018) found azuC gene expression responding linearly to pressures between 0 MPa to 1 MPa. The same authors still conclude:</p>

<p><em>"It is tempting to speculate that AzuC was upregulated in response to mild elevated pressure to maintain membrane stability just like Csps in higher pressure treatments."</em></p>

<p>Other authors found azuC over expressed under other stress conditions such as low pH, heat shock and oxidative stress, although it was regulated under low oxygen levels. AzuC, and other stress induced small membrane proteins, could stabilize the membrane by the modulation of other transmembrane proteins and also by interacting with the inner membrane changing its permeability (Hemm et al. 2010). This interaction with membranes, changing their permeability, is a key feature of many AMP classes.</p>

<p>A series of in silico tests were carried out on these sequences so as to screen for antimicrobial features or activities of the predicted peptides, we got interesting results that can serve as evidences supporting our speculation of AzuC being an AMP-like protein, furthermore, we went on to document some of its peptide features and also to model it. These results are the major scope of this write-up.</p>

<h2>Predicting the peptide</h2>
<p>We eliminated the identical sequences that matched to AzuC by using CD-HIT with sequence identity cut-off of 1.0 and overlap of the shorter sequence of 90%. We initially got 948 sequences clustered into 12 clusters. <a href="http://skylign.org/">Skylign</a> was used to create logos (below) of the 60bp upstream and downstream of the start and stop codons of each gene, respectively. Similarly to HG4, there is a ribosome binding site with a 7bp spacer in the upstream region, and on the downstream region, a stop codon. Thus there is a complete ORF that can be transcribed, including a terminator at the downstream portion.</p>

![figure1-upstream logo]({{ site.baseurl }}/assets/2020-08-21-AzuC:an unusual AMP candidate/figure1.png)
<div class="caption"><b>Figure 1</b>:Logo of the 60bp upstream region showing a ribosome binding site(RBS) and a 7bp spacer, along with a TATA box and the methionine start codon(Met).</div>
![figure2-downstream logo]({{ site.baseurl }}/assets/2020-08-21-AzuC:an unusual AMP candidate/figure2.png)
<div class="caption"><b>Figure 2</b>:Logo of the 60bp downstream region showing a stop codon and a Terminator with two clips.</div>

<p>After an evolutionary analysis of the azuC genes using <a href="http://selecton.tau.ac.il/">Selecton</a>, we found evidence of purifying selection. This was also supported by a negative Tajima’s D (-0.74), thus suggesting amino acid conservation. The found genes were very close to each other as shown in the phylogeny, suggesting they are closely related.</p>

![figure3 evolutionary tree]({{ site.baseur l}}/assets/2020-08-21-AzuC:an unusual AMP candidate/figure3.png)
<div class="caption"><b>Figure 3</b>:Evolutionary analysis by Maximum Likelihood method. The tree is drawn to scale, with branch lengths measured in the number of substitutions per site. This analysis involved 12 nucleotide sequences. Codon positions included were 1st+2nd+3rd+Noncoding. There were a total of 84 positions in the final dataset. Evolutionary analyses were conducted in MEGA X.</div>

<p>Features of a typical AMP could be verified in AzuC peptides, such as the amphiphilic profile, with the charged amino acids preferentially distributed in a side of the helical wheel. The other face of the wheel is occupied mostly by hydrophobic residues, which can also be seen in its hydrophobicity profile, with alternating sections of polar and hydrophobic regions. This alternancy is essential for AMPs to facilitate the insertion in membranes.</p>

![figure4and5 hydrophobicity and peptide wheel]({{ site.baseurl }}/assets/2020-08-21-AzuC:an unusual AMP candidate/figure3and4.png)
<div class="caption"><b>Figures 4 and 5</b>:Figure 4 (left) the hydrophobicity profile of the peptide showing that it is amphiphilic. Figure 5 (right) shows the helical wheel and the alternating sections of the polar and hydrophobic regions of the peptide.</div>


<p>The structure of AzuC protein was predicted using SwissModel (swissmodel.expasy.org/), and the overall quality measured by the QMEAN (0.25) was extremely close to an experimentally obtained model, also corroborated by the Z-value (<1). Altogether, these parameters suggest our model as feasible to infer at least some preliminary conclusions about azuC.</p>

<p>AzuC peptide model is shown in blue (below), and is clearly formed mostly by an alpha-helix, as most other AMPs (Zhang and Gallo, 2016). Like bacteriocins, it has an arm, with charged amino acids that can anchor in the membrane and stabilize the peptide/membrane complex. This model can be very useful in future work where we can test its interaction by docking against modelled membranes and verify its behaviour. After tests of melting, the structure showed to be thermodynamically stable with an RMSD of the structures of 3.0, and a maximum energy of -300 kJ/mol.</p>

![figure6and7 peptide features]({{ site.baseurl }}/assets/2020-08-21-AzuC:an unusual AMP candidate/figure5and6.png)
<div class="caption"><b>Figures 6 and 7</b>:Quality of the predicted protein model for the azuC protein showing a QMEAN score of 0.25 and a Z-value of <1.</div>

![figure8 peptide model]({{ site.baseurl }}/assets/2020-08-21-AzuC:an unusual AMP candidate/figure7.png)
<div class="caption"><b>Figures8</b>:Peptide model of azuC peptide as predicted using SwissModel. Showing an alpha-helix and an arm with charged amino acids.</div>


<h2>AzuC: an unusual AMP candidate</h2>

<p>As we found azuC in human guts samples, we tested the half life of it in intestines like environments by  using <a href="http://crdd.osdd.net/raghava/hlp/">HLP WebServer</a>. The half life of azuC peptide in human guts is 0.065s, in other words, it has low stability (half life < 0.1s - Sharma et al., 2014), suggesting short time to action or to be inactivated too quickly in the intestines. Although no signal peptides were predicted, azuC still has some AMP targets predicted using the special prediction tool from <a href="dbaasp.org/">DBAASP server</a>. AzuC was predicted to be active against <em>Klebsiella pneumonia</em> (0.85 PPV) and <em>Bacillus subtilis</em> (0.81 PPV), the latter a well-known spore-forming bacteria. The interest in the control of both bacteria and also the niche of both species in relation to E. coli makes azuC a good candidate for testing in vitro against these strains to check its effectiveness, although no actual evidence of its potency could be predicted.</p>

<p>Considering the origin of azuC genes, mostly from E. coli and other Gram negative microorganisms, its pattern of expression under stress conditions, and the clear interaction with membranes already documented and circumstantially linked to a modulation in plasticity, leads us to a funny line of thought:
	-azuC kept its properties and still is capable of interacting with membranes
	-its original function was killing competitor strains
	-no signal peptide was found and expression is up-regulated under stress
</p>

<p><em><center>AzuC is related to AMPs (maybe it evolved from sequences with AMP/signalling functions). However, it is no longer active, and the bacterium has co-opted it to other uses (likely modulating its own membrane).</center></em></p>


<H2>Conclusions and perspectives</H2>
<p>We need to understand that besides low stability, azuC lacks a signal peptide (cannot be secreted by conventional pathways) and is produced mostly in stress conditions. These pieces of evidence can lead us to conclude that AMPs can have other functions than killing microorganisms. Specifically, we are tempted to speculate that E. coli (the bacteria from which azuC gene was identified) is using the AMP features to modulate the plasticity of its own membrane and therefore modulate the cell shape and volume. This circumstantial evidence, if further corroborated in other genes, can show that AMPs could evolve into membrane proteins. Similar findings were recently reported by Garrido et al. (2020) where they show the emergence of targeting peptides from AMPs for the evolution of endosymbiotic protein targeting systems.</p>

<h2>REFERENCES</h2>
<p>Guyet A, Dade-Robertson M, Wipat A, Casement J, Smith W, Mitrani H, et al. (2018) Mild hydrostatic pressure triggers oxidative responses in Escherichia coli. PLoS ONE 13(7): e0200660. https://doi.org/10.1371/journal.pone.0200660

<p>Hemm MR, Paul BJ, Miranda-Rios J, Zhang AX, Soltanzad N, Storz G. Small Stress Response Proteins in Escherichia coli: Proteins Missed by Classical Proteomic Studies. J Bacteriol. 2010;192(1):46–58. WOS:000272636600006. pmid:19734316</p>

<p>Garrido, C.; Caspari, O.D.; Choquet, Y.; Wollman, F.-A.; Lafontaine, I. Evidence Supporting an Antimicrobial Origin of Targeting Peptides to Endosymbiotic Organelles. Cells 2020, 9, 1795.</p>

<p>Zhang LJ, Gallo RL. Antimicrobial peptides. Curr Biol. 2016;26(1):R14-R19. doi:10.1016/j.cub.2015.11.017</p>

<p>Sharma A, Singla D, Rashid M, Raghava GP. Designing of peptides with desired half-life in intestine-like environment. BMC Bioinformatics. 2014;15(1):282. Published 2014 Aug 20. doi:10.1186/1471-2105-15-282</p>
</p>
</body>
</html>
</div>
