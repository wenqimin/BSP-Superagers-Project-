
# use glmnet directly, rather than caret
# so can limit max number of parameters in fitted model

library(glmnet)
library(glue)
library(dplyr)
library(reshape2)
library(purrr)


#########################
# select tensor data

TENSOR <- "3T"
# TENSOR <- "7T"
# TENSOR <- "3T_xover"
# TENSOR <- "3T_quality"


# source("scripts/prep_data.R")

dat_list <- readRDS(file = glue("data/dat_list_{TENSOR}_n.RDS"))


####################
# fit model

res <-
  purrr::map(dat_list,
             function(.x) en_superagers_network(.x, caret = FALSE, pmax = 10))


#################
# post process

saveRDS(res, file = glue("data/elasticnet_res_glmnet_{TENSOR}.RDS"))

map(res, ~.x[["lambda"]])

# hard-coded lambda = 0.1
## how does this affect the results?...
coeffs <- map(res, ~coef(.x, s = 0.1))

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

write.csv(out_tab, file = glue("data/elasticnet_out_glmnet_{TENSOR}.csv"))
