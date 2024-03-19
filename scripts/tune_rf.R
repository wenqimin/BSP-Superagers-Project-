library(dplyr)
library(reshape2)
library(tidyr)
library(glue)
library(purrr)
library(party)
library(randomForest)

# set.seed(5234)
set.seed(123)
#? set.seed

## select tensor data

# TENSOR <- "3T"
 TENSOR <- "7T"


dat_list <- readRDS(file = glue("data/dat_list_{TENSOR}_n.RDS"))

#transform to wide format
dat_wide <- map(dat_list,~wide_format(.x))


set.seed(231)
##Choosing optimal mtry
tune_rf <- function(dat) {
  colnames(dat) <- make.names(colnames(dat))
  mtry <- tuneRF(dat[-ncol(dat)], as.factor(dat$status),ntreeTry=100000,
                 stepFactor=1.5,improve=0.01, trace=TRUE, plot=TRUE)
  
  mtry
}


mtry <- map(dat_wide,~tune_rf(.x))

png('tunerf_network_7T.png', height=480, width=720)
par(mfrow=c(2,3))
for (i in names(mtry)){
   mtry[[i]] <- as.data.frame(mtry[[i]])
   plot(mtry[[i]]$mtry,mtry[[i]]$OOBError,
        main=i,xlab='mtry',ylab='OOB Error')
   lines(mtry[[i]]$mtry,mtry[[i]]$OOBError)}
dev.off()

best.m <- list()
for (i in names(mtry)){
  best.m[[i]] <- mtry[[i]][mtry[[i]][, 2] == min(mtry[[i]][, 2]), 1]
}

##choosing optimal ntree
set.seed(231)
res <-
  map(dat_wide, ~superagers_rf(.x,mtry=10,ntree=10000))



png("tunerf_ntree7T_10000.png", height=480, width=720)
par(mfrow=c(2,3))
resplot <- list()
for (i in names(res)){
  resplot[[i]] <- plot(res[[i]],main=i)}
dev.off()


