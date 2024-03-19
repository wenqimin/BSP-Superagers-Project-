library(dplyr)
library(reshape2)
library(tidyr)
library(glue)
library(purrr)
library(party)
library(randomForest)

# set.seed(5234)
set.seed(123)


## select tensor data

# TENSOR <- "3T"
TENSOR <- "7T"


dat_list <- readRDS(file = glue("data/dat_list_{TENSOR}_n.RDS"))


#transform to wide format
dat_wide <- map(dat_list,~wide_format(.x))



## run the random forest model
res <- map(dat_wide, ~superagers_rf(.x,ntree=10000,mtry=10))

saveRDS(res, file = glue("data/randomforest_network_{TENSOR}.RDS"))



par(mfrow=c(2,3))
impplot <- map2(res,names(res),~varImpPlot(.x,sort=T, n.var= 10, 
                    main= .y, pch=16))









