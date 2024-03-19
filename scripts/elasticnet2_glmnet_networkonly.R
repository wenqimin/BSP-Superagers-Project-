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

dat_wide <- map(dat_list, ~wide_format(.))

####################
# fit model
alpha <- 0.5
lambda <- 0.3
res <- list()
for (i in names(dat_wide)){
   dat <- dat_wide[[i]]
   res[[i]] <- glmnet(x = as.matrix(select(dat, -status)),
               y =  as.factor(dat$status),
               family = "binomial",
               alpha = alpha,
               standardize = TRUE,
               nfolds = 10)
}
 


#################
# post process

saveRDS(res, file = glue("data/elasticnet_res2_glmnet_{TENSOR}.RDS"))

map(res, ~.x[["lambda"]])

# hard-coded lambda = 0.1
## how does this affect the results?...
coeffs <- map(res, ~coef(.x, s = lambda))

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

write.csv(out_tab, file = glue("data/elasticnet_out2_glmnet_{TENSOR}.csv"))
