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

# TENSOR <- "3T"
 TENSOR <- "7T"
# TENSOR <- "3T_xover"
# TENSOR <- "3T_quality"

# source("scripts/prep_data.R")
dat_list <- readRDS(file = glue("data/dat_list_{TENSOR}_n.RDS"))
# dat_list_t1 <- readRDS(file = glue("data/dat_list_t1.RDS"))





############
# analysis #
############
# varying alpha, lambda using caret

keep_network <- c("DMN", "Salience", "ECN_L", "ECN_R", "Hippocampal", "Language")
nfolds <- 10
alpha_seq <- c(0, 0.01, 0.1, 0.15, 0.5, 1)
lambda_seq <- c(0.4, 0.3, 0.2, 0.15, 0.1, 0.05, 0.04, 0.03, 0.02, 0.01, 0.005)
#lambda_seq <- c(1, 0.9, 0.8, 0.7, 0.6, 0.5, 0.4, 0.3, 0.2, 0.1, 0.01)
#lambda_seq <- c(0.1, 0.3, 1, 10, 20, 50, 100, 200)
caret_res <- list()

for (j in keep_network) {
  
  # elastic net superagers by network
  caret_res[[j]] <-
    en_superagers_grid(
      dat = dat_list[[j]],
      lambda_seq = lambda_seq,
      alpha_seq = alpha_seq,
      nfolds = nfolds)
}

bestTune <- map(caret_res, pluck, "bestTune") %>%
            do.call(rbind,.)


##########
# plots

library(gridExtra)

## Heatmap of all 625 pairs alpha and lambda
trellis.par.set(caretTheme())
gridres <- list()
for (i in names(caret_res)){
  caret_res[[i]][["results"]]$alpha <- round(caret_res[[i]][["results"]]$alpha,3)
  caret_res[[i]][["results"]]$lambda <- round(caret_res[[i]][["results"]]$lambda,3)
  gridres[[i]] <- plot(caret_res[[i]], metric = "Accuracy", plotType = "level",
                       scales = list(x = list(rot = 90)),
                       main=i,xlab='Alpha',ylab='Lambda')
}



gridres
do.call("grid.arrange", c(gridres, ncol=2))



ggres <- list()

for (i in names(caret_res)) {
  ggres[[i]] <-
    ggplot(caret_res[[i]], nameInStrip = TRUE, metric = "Accuracy") +
    ggtitle(i)+
    xlab("Lambda") + ylab("Accuracy")+
    scale_color_discrete(name = "Alpha")  +
    scale_shape_discrete(name = "Alpha")
}

ggres_grid <-do.call("grid.arrange", c(ggres, ncol=2))
ggsave("output/alpha-Lambda Accuracy Plot-caret-7T.png",ggres_grid,
       width = 10, height = 10, dpi = 300)


