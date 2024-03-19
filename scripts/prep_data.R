
# prep_data.R
#
# rearrange and filter data
# before main analysis


# # overdrive folder
# url <- ""
# dir <- here::here("raw_data")
# download.file(url, destfile = dir)
# ct_dat <- readr::read_csv(dir, ...)


library(glue)
library(dplyr)
library(reshape2)
library(tidyr)

# select
TENSOR <- "7T" # "3T"

ct_dat <-
  readRDS(here::here(glue("raw_data/crt_{TENSOR}_zv.rds")))

sa_dat <-
  readRDS(here::here(glue("raw_data/sa_{TENSOR}_zv.rds")))

# remove columns
ct_dat <-
  ct_dat[, !names(ct_dat) %in% c(
    "Machine",
    "Type",
    "Subject",
    "Gender",
    "Age",
    "Date_GraphICA",
    "Manufacturer",
    "Model")]
sa_dat <-
  sa_dat[, !names(sa_dat) %in% c(
    "Machine",
    "Type",
    "Subject",
    "Gender",
    "Age",
    "Date_GraphICA",
    "Manufacturer",
    "Model")]

# dataframe: id, region, network, value
ct_long <-
  ct_dat %>%
  mutate(id = 1:n()) %>%
  melt(id.vars = "id") %>%
  separate(variable, c("region", "network")) %>%
  mutate(region = as.numeric(region),
         network = as.numeric(network) + 1,
         network = ifelse(is.na(network), 1, network))

sa_long <-
  sa_dat %>%
  mutate(id = 1:n()) %>%
  melt(id.vars = "id") %>%
  separate(variable, c("region", "network")) %>%
  mutate(region = as.numeric(region),
         network = as.numeric(network) + 1,
         network = ifelse(is.na(network), 1, network))

network_names <-
  c('Auditory',
    'DMN',
    'ECN_L',
    'ECN_R',
    'Hippocampal',
    'Language',
    'Salience',
    'Sensorimotor',
    'Visual_lateral',
    'Visual_medial',
    'Visual_occipital')

NETWORK_NAMES <-
  data.frame(network = seq_along(network_names),
             network_name = network_names)

# network masks (subset of regions)
list_nodes_network_male <-
  readRDS("raw_data/list_nodes_network_male.rds") %>%
  setNames(NETWORK_NAMES$network_name)

# region names lookup
regions <-
  readr::read_csv(here::here("raw_data/position.csv")) %>%
  select(-x, -y, -z)

save(regions, file = "data/regions.RData")

# subset networks
keep_network <- c("DMN", "Salience", "ECN_L", "ECN_R", "Hippocampal", "Language")
n_networks <- length(keep_network)

# separate dataframes for each network
ct_list <-
  ct_long %>%
  merge(regions, by.x = "region", by.y = "Region") %>%
  merge(NETWORK_NAMES, by = "network") %>%
  filter(network_name %in% keep_network) %>%
  split(.$network_name)

sa_list <-
  sa_long %>%
  merge(regions, by.x = "region", by.y = "Region") %>%
  merge(NETWORK_NAMES, by = "network") %>%
  filter(network_name %in% keep_network) %>%
  split(.$network_name)

dat_list <- list()

# filter by mask

for (i in keep_network) {
  
  dat_list[[i]]$ct_long <-
    ct_list[[i]] %>%
    filter(Label %in% list_nodes_network_male[[i]])
  
  dat_list[[i]]$sa_long <-
    sa_list[[i]] %>%
    filter(Label %in% list_nodes_network_male[[i]])
}

saveRDS(dat_list, file = glue("data/dat_list_{TENSOR}_n.RDS"))

