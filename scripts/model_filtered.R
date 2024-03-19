library(dplyr)
library(reshape2)
library(tidyr)
library(glue)
library(purrr)
library(party)
library(randomForest)
library(glmnet)

# set.seed(5234)
set.seed(123)
#? set.seed

## select tensor data

# TENSOR <- "3T"
 TENSOR <- "7T"


dat_list <- readRDS(file = glue("data/dat_filtered_{TENSOR}.RDS"))



set.seed(231)

## train the random forest model
rf_model <- superagers_rf(dat_list ,ntree=100,mtry=6)

impplot <- varImpPlot(rf_model,sort=T, n.var= 10, pch=16)

saveRDS(rf_model, file = glue("data/randomforest_filtered_{TENSOR}.RDS"))




#train the penalized logistic model
en_model <- glmnet(dat_list[-ncol(dat_list)],dat_list$status,
             family='binomial',
             alpha=1,
             standardize = TRUE,
             nfolds = 10)

coef(en_model,s=c(0.1,0.2,0.3))