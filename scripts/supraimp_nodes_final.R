#nodes of final supranormal importance after two runs of random forest
#include all network
library(ggplot2)
library(dplyr)

# set.seed(5234)
set.seed(123)
#? set.seed

## select tensor data

# TENSOR <- "3T"
TENSOR <- "7T"

res <- readRDS(file = glue("data/rf_res_{TENSOR}_includemdg.RDS"))

mdg <- importance(res, type = 2)
mdg <- as.data.frame(mdg)

nodes <- rownames(mdg)
network <- list()
region <- list()
for (i in 1:length(nodes)){
string <- nodes[i]
split_string <- strsplit(string, ".", fixed = TRUE)[[1]]
network[i] <- split_string[1]
region[i] <- paste(split_string[-1], collapse = "_")
}

out <- cbind(network,region,mdg$MeanDecreaseGini)
out <- as.data.frame(out)
names(out)[3] <- "importance"
out$importance <-as.numeric(out$importance)



comb_out <- comb_supraimp(out)


saveRDS(comb_out, file = glue("data/randomforest_mdg_final{TENSOR}.RDS"))


#mda
res <- readRDS(file = glue("data/rf_res_{TENSOR}_includemda.RDS"))

mda <- importance(res, type = 1)
mda <- as.data.frame(mda)

nodes <- rownames(mda)
network <- list()
region <- list()
for (i in 1:length(nodes)){
  string <- nodes[i]
  split_string <- strsplit(string, ".", fixed = TRUE)[[1]]
  network[i] <- split_string[1]
  region[i] <- paste(split_string[-1], collapse = "_")
}

out <- cbind(network,region,mda$MeanDecreaseAccuracy)
out <- as.data.frame(out)
names(out)[3] <- "importance"
out$importance <-as.numeric(out$importance)



comb_out <- comb_supraimp(out)


saveRDS(comb_out, file = glue("data/randomforest_mda_final{TENSOR}.RDS"))