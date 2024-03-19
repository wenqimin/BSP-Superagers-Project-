#Filter the variables to leave the ones with supranormal importance
#dat should be dataframe with network,region,importance as column
comb_supraimp <- function(dat){

avg_imp <- dat %>%
  group_by(network) %>%
  summarise(avg_imp = mean(importance)) %>%
  ungroup()


sd_imp <- dat %>%
  group_by(network) %>%
  summarise(sd_imp = sd(importance)) %>%
  ungroup()

imp_summary <- left_join(avg_imp, sd_imp, by = "network")

#upper_thresh <- imp_summary$avg_imp + 1.5*imp_summary$sd_imp
upper_thresh <- imp_summary$avg_imp + imp_summary$sd_imp

# filter dataframe to include only regions with importance greater than upper threshold
filtered <- dat %>%
  filter(importance > upper_thresh) %>%
  select(network, region, importance)


comb <-
  filtered |>
  mutate(region_stem = gsub("\\_\\d*$", "", region)) |>
  group_by(region_stem, network) |>
  summarise(mean_importance = mean(importance)) |>
  ungroup() 

comb
}


