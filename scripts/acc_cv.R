#Compare the performance of models using accuracy on the original data set
library(caret)
library(purrr)
library(ROCR)
library(glmnet)
library(randomForest)
library(gridExtra)
library(glue)
library(dplyr)
library(reshape2)


dat_list_3T <- readRDS(file = glue("data/dat_list_3T_n.RDS"))
dat_list_7T <- readRDS(file = glue("data/dat_list_7T_n.RDS"))

dat_wide_3T <- map(dat_list_3T, ~wide_format(.x))
dat_wide_7T <- map(dat_list_7T, ~wide_format(.x))

rf_3T <-  readRDS(file = glue("data/randomforest_network_3T.RDS"))
rf_7T <-  readRDS(file = glue("data/randomforest_network_7T.RDS"))
en_3T <-  readRDS(file = glue("data/elasticnet_res2_glmnet_3T.RDS"))
en_7T <-  readRDS(file = glue("data/elasticnet_res2_glmnet_7T.RDS"))


control <- trainControl(method="repeatedcv", number=10, repeats=3)
set.seed(123)
KEEP_NETWORK <- names(dat_wide_3T)
acc.rf <-list()
for (j in KEEP_NETWORK){
   colnames(dat_wide_3T[[j]]) <-make.names(colnames(dat_wide_3T[[j]]))
   acc.rf[['3T']][[j]] <- train(status~., data=dat_wide_3T[[j]], 
                              method="rf", trControl=control,
                              tuneGrid=expand.grid(.mtry=10),ntree=10000)
 
   colnames(dat_wide_7T[[j]]) <-make.names(colnames(dat_wide_7T[[j]]))
   acc.rf[['7T']][[j]] <- train(status~., data=dat_wide_7T[[j]], 
                              method="rf", trControl=control,
                              tuneGrid=expand.grid(.mtry=10),ntree=10000)}

acc.en <-list()
for (j in KEEP_NETWORK){
  colnames(dat_wide_3T[[j]]) <-make.names(colnames(dat_wide_3T[[j]]))
  acc.en[['3T']][[j]] <- train(status~., data=dat_wide_3T[[j]], 
                               method="glmnet", trControl=control,
                               tuneGrid=expand.grid(.alpha=0.5,.lambda=0.3))
  
  colnames(dat_wide_7T[[j]]) <-make.names(colnames(dat_wide_7T[[j]]))
  acc.en[['7T']][[j]] <- train(status~., data=dat_wide_7T[[j]], 
                               method="glmnet", trControl=control,
                               tuneGrid=expand.grid(.alpha=0.5,.lambda=0.3))}

acc.lasso <-list()
for (j in KEEP_NETWORK){
  colnames(dat_wide_3T[[j]]) <-make.names(colnames(dat_wide_3T[[j]]))
  acc.lasso[['3T']][[j]] <- train(status~., data=dat_wide_3T[[j]], 
                               method="glmnet", trControl=control,
                               tuneGrid=expand.grid(.alpha=1,.lambda=0.1))
  
  colnames(dat_wide_7T[[j]]) <-make.names(colnames(dat_wide_7T[[j]]))
  acc.lasso[['7T']][[j]] <- train(status~., data=dat_wide_7T[[j]], 
                               method="glmnet", trControl=control,
                               tuneGrid=expand.grid(.alpha=1,.lambda=0.1))}

plot_acc_3T <- list()
plot_acc_7T <- list()
results <- list()
for (j in KEEP_NETWORK){
results[['3T']][[j]] <- resamples(list(RF=acc.rf[['3T']][[j]],EN=acc.en[['3T']][[j]],
                                       LASSO=acc.lasso[['3T']][[j]]))
results[['7T']][[j]] <- resamples(list(RF=acc.rf[['7T']][[j]],EN=acc.en[['7T']][[j]],
                                       LASSO=acc.lasso[['7T']][[j]]))
scales <- list(x=list(relation="free"), y=list(relation="free"))


plot_acc_3T[[j]] <- bwplot(results[['3T']][[j]], scales=scales,main=paste0('3T ',j),
                           metric="Accuracy")
plot_acc_7T[[j]] <- bwplot(results[['7T']][[j]], scales=scales,main=paste0('7T ',j),
                           metric="Accuracy")
}


for (i in 1:length(KEEP_NETWORK)){
  png(paste0(KEEP_NETWORK[i],"accuracy_comparison.png"),width=240,height=240)
  do.call("grid.arrange",c(plot_acc_3T[i],plot_acc_7T[i],ncol=2))
  dev.off()}

