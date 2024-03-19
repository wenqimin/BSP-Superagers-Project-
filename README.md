# Phenotyping Superagers using Resting-State Functional Magnetic Resonance Imaging: A Comparison of Penalised Regression and Random Forest

This project includes three parts:
## 1. Phenotyping Superagers with Penalised regression
This part is adapted from Dr Nathan Green @n8thangreen. Their project can be found under this link: https://github.com/n8thangreen/superager.penalised.regn.
I have reproduced the lolliplot graph with different set of parameters.
## 2. Phenotyping Superagers with Random Forest using Pre-selected Regions
In this part, I ran random forest model in each of the six preselected regions.
[Random Forest by Network](scripts/randomforest_network.R)
## 3. Phenotyping Superagers with Random Forest using All Regions
I included datapoints from all of the regions and ran the random forest model twice. Lolliplots of the most important nodes are produced for both 3T and 7T data. Here important nodes refer to nodes that have a high MDA/MDG score.
