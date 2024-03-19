superagers_rf <- function(dat,mtry=11,ntree=500) {

colnames(dat) <- make.names(colnames(dat))
  
output.rf <- randomForest(as.factor(dat$status) ~ .,
                                data = dat,
                                mtry=mtry,ntree=ntree,
                                importance=TRUE)

output.rf
#importance(output.rf)

}

