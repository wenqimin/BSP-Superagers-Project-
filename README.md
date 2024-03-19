# Phenotyping Superagers using Resting-State Functional Magnetic Resonance Imaging: A Comparison of Penalised Regression and Random Forest

This project includes three parts:
## 1. Phenotyping Superagers with Penalised regression
This part is adapted from Dr Nathan Green @n8thangreen. Their project can be found under this link: https://github.com/n8thangreen/superager.penalised.regn.
I have reproduced the lolliplot graph with different set of parameters.
## 2. Phenotyping Superagers with Random Forest using Pre-selected Regions
### Analysis
[Random Forest by Network](scripts/randomforest_network.R) Runs random forest model in each of the six preselected regions. <br>
[Important Nodes in Pre-selected Regions](scripts/rf_imp_network.R) Identify the most important nodes in each of the region. Here important nodes refer to nodes that have a high MDA/MDG score.


### Output
[Importance Lolliplot](scripts/imp_lolliplot.R) Produces all the lolliplots below. <br>

<p align="middle">
  <img src="output/mda_lolliplot_3T_merged_network.png" width="200" />
  <img src="output/mdg_lolliplot_3T_merged_network.png" width="200" />
</p>

<p align="middle">
  <img src="output/mda_lolliplot_7T_merged_network.png" width="200" />
  <img src="output/mdg_lolliplot_7T_merged_network.png" width="200" />
</p>


[Prediction Fit](scripts/output_rf_stats_plot.R) This is adapted from @n8thangreen to produce a scatter plot to compare the fit of 3T and 7T data. <br>
[Prediction Accuracy](output/rf_scatterplot_3T_7T.pdf)
## 3. Phenotyping Superagers with Random Forest using All Regions
### Analysis
[Repeated Random Forest on all Data](scripts/randomforest_includeall.R) Runs the random forest model twice on nodes from all the regions. <br>
[Important Nodes in All Regions](scripts/supraimp_nodes_final.R) Identifies the most important nodes out of nodes from all regions.
### Output
[Importance Lolliplot](scripts/imp_lolliplot.R) Produces all the lolliplots below. <br>

<p align="middle">
  <img src="output/mda_lolliplot_3T_merged_final.png" width="200" />
  <img src="output/mdg_lolliplot_3T_merged_final.png" width="200" />
</p>

<p align="middle">
  <img src="output/mda_lolliplot_7T_merged_final.png" width="200" />
  <img src="output/mdg_lolliplot_7T_merged_final.png" width="200" />
</p>




