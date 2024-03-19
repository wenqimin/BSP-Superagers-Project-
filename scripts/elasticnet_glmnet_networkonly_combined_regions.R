
# use glmnet directly, rather than caret
# so can limit max number of parameters in fitted model

library(glmnet)
library(glue)
library(dplyr)
library(reshape2)
library(purrr)


#########################
# select tensor data

# TENSOR <- "3T"
 TENSOR <- "7T"
# TENSOR <- "3T_xover"
# TENSOR <- "3T_quality"


# source("scripts/prep_data.R")

dat_list <- readRDS(file = glue("data/dat_list_{TENSOR}_n.RDS"))

# combine like regions and mean values

dat_comb <- list()

for (i in names(dat_list)) {
  
  dat_comb[[i]] <- list()
  
  dat_comb[[i]][["ct_long"]] <-
    dat_list[[i]]$ct_long |>
    mutate(Label = as.character(Label),
           Label = gsub("\\_\\d*$", "", Label)) |>
    group_by(id, network, network_name, Label) |>
    summarise(value = mean(value)) |>
    ungroup() |>
    mutate(region = as.numeric(as.factor(Label)))
  
  dat_comb[[i]][["sa_long"]] <-
    dat_list[[i]]$ct_long |>
    mutate(Label = as.character(Label),
           Label = gsub("\\_\\d*$", "", Label)) |>
    group_by(id, network, network_name, Label) |>
    summarise(value = mean(value)) |>
    ungroup() |>
    mutate(region = as.numeric(as.factor(Label)))
}

dat_list <- dat_comb


####################
# fit model

res <-
  purrr::map(dat_list,
             function(.x) en_superagers_network(.x, caret = FALSE, pmax = 10))


#################
# post process

saveRDS(res, file = glue("data/elasticnet_res_glmnet_comb_regn_{TENSOR}.RDS"))

map(res, ~.x[["lambda"]])

# hard-coded lambda = 0.1
## how does this affect the results?...
coeffs <- map(res, ~coef(.x, s = 0))
coeffs

# final output array
out <-
  map(coeffs,
      function(.x)
        data.frame(value = .x@x,
                   ids = .x@i,
                   region = .x@Dimnames[[1]][.x@i + 1]) %>%
        mutate(or = round(exp(value), 4)))

out

out_tab <- bind_rows(out, .id = "network")

knitr::kable(out_tab)

write.csv(out_tab, file = glue("data/elasticnet_out_glmnet_comb_regn_{TENSOR}.csv"))
