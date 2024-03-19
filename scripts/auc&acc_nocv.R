#Compare the performance of models using accuracy and ROC-AUC on the original data set
library(caret)
library(purrr)
library(ROCR)
library(glmnet)
library(randomForest)



dat_list_3T <- readRDS(file = glue("data/dat_list_3T_n.RDS"))
dat_list_7T <- readRDS(file = glue("data/dat_list_7T_n.RDS"))

dat_wide_3T <- map(dat_list_3T, ~wide_format(.x))
dat_wide_7T <- map(dat_list_7T, ~wide_format(.x))

rf_3T <-  readRDS(file = glue("data/randomforest_network_3T.RDS"))
rf_7T <-  readRDS(file = glue("data/randomforest_network_7T.RDS"))
en_3T <-  readRDS(file = glue("data/elasticnet_res2_glmnet_3T.RDS"))
en_7T <-  readRDS(file = glue("data/elasticnet_res2_glmnet_7T.RDS"))


###accuracy and auc for random forest model on the training set
KEEP_NETWORK <- names(dat_wide_3T)
ppred <- list()
pred <- list()
auc <- list()
roc <- list()
cpred <- list()
cm <- list()
acc <- list()
for (j in KEEP_NETWORK){
   dat <- dat_wide_7T[[j]]
   res <- rf_7T[[j]]
   ppred[[j]] <- predict(res, type='prob')[,2]
   pred[[j]] <- prediction(ppred[[j]], dat$status)
   roc[[j]] <- performance(pred[[j]], measure = "tpr", x.measure = "fpr") 
   plot(roc[[j]],main=j)
   auc[[j]] <- performance(pred[[j]],measure = "auc")@y.values
   abline(0,1)
   
   cpred[[j]] <- predict(res, type='class')
   cm[[j]] <- confusionMatrix(cpred[[j]], dat$status)
   acc[[j]] <- cm[[j]]$overall["Accuracy"]
   
}

ppred <- list()
pred <- list()
auc <- list()
roc <- list()
cpred <- list()
cm <- list()
acc <- list()
for (j in KEEP_NETWORK){
  dat <- dat_wide_3T[[j]]
  res <- en_3T[[j]]
  ppred[[j]] <- predict(res,newx=as.matrix(dat[-ncol(dat)]),s=0.3,type="response")
  pred[[j]] <- prediction(ppred[[j]], dat$status)
  roc[[j]] <- performance(pred[[j]], measure = "tpr", x.measure = "fpr") 
  plot(roc[[j]],main=j)
  auc[[j]] <- performance(pred[[j]],measure = "auc")@y.values
  abline(0,1)

  cpred[[j]] <- as.factor(predict(res,newx=as.matrix(dat[-ncol(dat)]),s=0.3, type='class'))
  cm[[j]] <- confusionMatrix(cpred[[j]], dat$status)
  acc[[j]] <- cm[[j]]$overall["Accuracy"]
}