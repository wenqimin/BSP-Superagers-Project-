#It accepts the list of most important nodes from first run of random forest and combine it
library(dplyr)

# set.seed(5234)
set.seed(123)
#? set.seed

## select tensor data

# TENSOR <- "3T"
TENSOR <- "7T"

##Select mdg or mda
# IMPORTANCE <- "mdg"
IMPORTANCE <- "mda"



imp <- readRDS(file = glue("data/{IMPORTANCE}_1strf_{TENSOR}.RDS"))


nodes <- rownames(imp)
network <- list()
region <- list()
for (i in 1:length(nodes)){
  string <- nodes[i]
  split_string <- strsplit(string, ".", fixed = TRUE)[[1]]
  network[i] <- split_string[1]
  region[i] <- paste(split_string[-1], collapse = "_")
}


out <- cbind(network,region,imp$MeanDecreaseAccuracy)
#out <- cbind(network,region,imp$MeanDecreaseGini)
out <- as.data.frame(out)
names(out)[3] <- "importance"
out$importance <-as.numeric(out$importance)

comb_out <-
  out |>
  mutate(region_stem = gsub("\\_\\d*$", "", region)) |>
  group_by(region_stem, network) |>
  summarise(mean_importance = mean(importance)) |>
  ungroup() 

comb_out

saveRDS(comb_out, file = glue("data/{IMPORTANCE}_1strf_{TENSOR}_comb.RDS"))