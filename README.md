# Phenotyping Superagers using Resting-State Functional Magnetic Resonance Imaging: A Comparison of Penalised Regression and Random Forest

This project includes three parts:
## 1. Phenotyping Superagers with Penalised regression
This part is adapted from Dr Nathan Green @n8thangreen. Their project can be found under this link: https://github.com/n8thangreen/superager.penalised.regn.
I have reproduced the lolliplot graph with different set of parameters.
## 2. Phenotyping Superagers with Random Forest using Pre-selected Regions
### Analysis
[Random Forest by Network](scripts/randomforest_network.R) In this part, I ran random forest model in each of the six preselected regions.
[Important Nodes in Pre-selected Regions](scripts/rf_imp_network.R) Then I identified the most important nodes in each of the region. Here important nodes refer to nodes that have a high MDA/MDG score.

### Output

## 3. Phenotyping Superagers with Random Forest using All Regions
### Analysis
[Repeated Random Forest on all Data] (scripts/randomforest_includeall.R) I included datapoints from all of the regions and ran the random forest model twice. Lolliplots of the most important nodes are produced for both 3T and 7T data. 
### Output

