# elastic net regression
# how does lambda change between fits?
# N Green

# *notation*
#
# alpha: split between lasso and ridge regression
# lambda: penalty
#
# lambda*[(1 - alpha)*beta2 + alpha*beta1]


library(caret)
library(dplyr)
library(reshape2)
library(tidyr)
library(glue)
library(purrr)
library(glmnet)


# set.seed(5234)
set.seed(123)


#########################
# select tensor data

TENSOR <- "3T"
# TENSOR <- "7T"
# TENSOR <- "3T_xover"
# TENSOR <- "3T_quality"

# source("scripts/prep_data.R")
 dat_list <- readRDS(file = glue("data/dat_list_{TENSOR}_n.RDS"))
# dat_list <- readRDS(file = glue("data/dat_list_t1.RDS"))


############
# analysis #
############
# varying alpha, lambda

keep_network <- c("DMN", "Salience", "ECN_L", "ECN_R", "Hippocampal", "Language")
alpha_seq <- c(0, 0.01, 0.1, 0.15, 0.5, 1)
lambda_grid <- c(1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.01)
res <- list()

for (j in keep_network) {
  
  res[[j]] <- list()
  
  for (i in seq_along(alpha_seq)) {
    
    res[[j]][["alpha"]][[as.character(alpha_seq[i])]] <-
      en_superagers_network(
        dat = dat_list[[j]],
        caret = FALSE,
        lambda_grid = lambda_grid,
        alpha = alpha_seq[i])
  }
  
  res[[j]]$lambda <- purrr::map(res[[j]]$alpha, ~.$lambda.1se)
  res[[j]]$coef_vals <- purrr::map(res[[j]]$alpha, coef, s = "lambda.1se")
  
  # number of non-zero coefficients
  res[[j]]$coef_num <- map(res[[j]]$coef_vals, ~sum(.[, "s1"] != 0))
}


##########
# tables #
##########

# number of coefficients per alpha

alpha_tab <- NULL

for (i in seq_along(res)) {
  alpha_tab <-
    rbind(alpha_tab,
          unlist(res[[i]]$coef_num))
}

rownames(alpha_tab) <- names(res)
alpha_tab

write.csv(alpha_tab, file = glue::glue("data/alpha_tab_{TENSOR}.csv"))
