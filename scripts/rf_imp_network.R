
#nodes of supranormal importance of in each network
library(ggplot2)
library(dplyr)

# set.seed(5234)
set.seed(123)
#? set.seed

## select tensor data

# TENSOR <- "3T"
TENSOR <- "7T"

res <- readRDS(file = glue("data/randomforest_network_{TENSOR}.RDS"))

#extract mda and mdg from random forest model
mdg <- list()
mda <- list()
for (i in names(res)){
mdg[[i]] <- importance(res[[i]], type = 2)
mdg[[i]] <- as.data.frame(mdg[[i]])
mdg[[i]] <- cbind(region = rownames(mdg[[i]]), mdg[[i]])
rownames(mdg[[i]]) <- 1:nrow(mdg[[i]])

mda[[i]] <- importance(res[[i]], type = 1)
mda[[i]] <- as.data.frame(mda[[i]])
mda[[i]] <- cbind(region = rownames(mda[[i]]), mda[[i]])
rownames(mda[[i]]) <- 1:nrow(mda[[i]]) 

}

#combine regions
mdg_bind <- bind_rows(mdg,.id="network")
mda_bind <- bind_rows(mda,.id="network")

names(mdg_bind)[3] <- "mdg"
names(mda_bind)[3] <- "mda"

 
avg_mdg <- mdg_bind %>%
  group_by(network) %>%
  summarise(avg_mdg = mean(mdg)) %>%
  ungroup()

avg_mda <- mda_bind %>%
  group_by(network) %>%
  summarise(avg_mda = mean(mda)) %>%
  ungroup()

sd_mdg <- mdg_bind %>%
  group_by(network) %>%
  summarise(sd_mdg = sd(mdg)) %>%
  ungroup()

sd_mda <- mda_bind %>%
  group_by(network) %>%
  summarise(sd_mda = sd(mda)) %>%
  ungroup()

mdg_summary <- left_join(avg_mdg, sd_mdg, by = "network")
mda_summary <- left_join(avg_mda, sd_mda, by = "network")

#upper_thresh <- mdg_summary$avg_mdg + 1.5*mdg_summary$sd_mdg
mdg_thresh <- mdg_summary$avg_mdg + mdg_summary$sd_mdg
mda_thresh <- mda_summary$avg_mda + mda_summary$sd_mda

# filter dataframe to include only regions with importance greater than upper threshold
mdg_filtered <- mdg_bind %>%
  filter(mdg > mdg_thresh) %>%
  select(network, region, mdg)

mda_filtered <- mda_bind %>%
  filter(mda > mda_thresh) %>%
  select(network, region, mda)

mdg_comb <-
  mdg_filtered |>
  mutate(region_stem = gsub("\\_\\d*$", "", region)) |>
  group_by(region_stem, network) |>
  summarise(mean_mdg = mean(mdg)) |>
  ungroup() 

mda_comb <-
  mda_filtered |>
  mutate(region_stem = gsub("\\_\\d*$", "", region)) |>
  group_by(region_stem, network) |>
  summarise(mean_mda = mean(mda)) |>
  ungroup() 


saveRDS(mdg_comb, file = glue("data/randomforest_mdg_network{TENSOR}.RDS"))
saveRDS(mda_comb, file = glue("data/randomforest_mda_network{TENSOR}.RDS"))

