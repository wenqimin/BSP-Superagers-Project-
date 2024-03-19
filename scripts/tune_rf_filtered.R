library(dplyr)
library(reshape2)
library(tidyr)
library(glue)
library(purrr)
library(party)
library(randomForest)

# set.seed(5234)
set.seed(123)
#? set.seed

## select tensor data

TENSOR <- "3T"
# TENSOR <- "7T"

#wilcoxon
dat_wide <- readRDS(file = glue("data/dat_wcfiltered_{TENSOR}.RDS"))

#rf
# dat_wide <- readRDS(file = glue("data/dat_formatted_{TENSOR}.RDS"))
# dat_wide <- readRDS(file = glue("data/dat_rffiltered_{TENSOR}.RDS"))

set.seed(231)

##Choosing optimal mtry
tune_mtry <- function(dat) {
  colnames(dat) <- make.names(colnames(dat))
  mtry <- tuneRF(dat[-ncol(dat)], as.factor(dat$status),ntreeTry=100000,
                 stepFactor=1.5,improve=0.01, trace=TRUE, plot=TRUE)
  
  mtry
}


mtry <- tune_mtry(dat_wide)


best.m <- mtry[mtry[, 2] == min(mtry[, 2]), 1]



##choosing optimal ntree
res <- superagers_rf(dat_wide ,ntree=20000, mtry=best.m)

resplot <- plot(res)



