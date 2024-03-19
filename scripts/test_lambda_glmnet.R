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
# dat_list_t1 <- readRDS(file = glue("data/dat_list_t1.RDS"))

dat_wide <- map(dat_list,~wide_format(.x))


#checking correlation between variables
cor <- list()
corcount <- list()
for (i in names(dat_wide)){
  cor[[i]] <- cor(dat_wide[[i]][1:ncol(dat_wide[[i]])-1])
  corcount[[i]] <- sum(abs(cor[[i]])>0.8)
  corcount[[i]]$pc <- (corcount[[i]]/nrow(cor[[i]])^2)*100
}

#visualize correlation
png("Corrplot-3T.png", width=720, height=480)
library(corrplot)
par(mfrow=c(2,3),mar = c(4, 4, 6, 2) + 0.4)
corrplot <- list()
for (i in names(cor)){
  corrplot[[i]] <- corrplot(abs(cor[[i]]), 
                            method = 'color', col.lim=c(0,1),type = 'lower', diag = FALSE,
                            tl.pos = 'n')
  title(main = i, line = 3)}
dev.off()

keep_network <- c("DMN", "Salience", "ECN_L", "ECN_R", "Hippocampal", "Language")
alpha_seq <- c(0, 0.01, 0.1, 0.15, 0.5, 1)
lambda_seq <- c(0.4, 0.3, 0.2, 0.15, 0.1, 0.05, 0.04, 0.03, 0.02, 0.01, 0.005)

##Analysis via glmnet package
##Varying alpha and lambda

pmax <-10
for (j in keep_network) {
  dat <-dat_wide[[j]]
  png(paste0('alpha and lambda plot ',j,' 3T.png'),width=720,height=480)
  par(mfrow=c(2,3),mar = c(4, 4, 6, 2) + 0.1)
  for (k in alpha_seq){
    model <- glmnet(dat[-ncol(dat)],dat$status,
                    family='binomial',
                    alpha=k,
                    #pmax=pmax,
                    standardize = TRUE,
                    nfolds = 10)
    plot(model,xvar="lambda",main=paste0('alpha=',k))
  }
  mtext(j, side=3, line=30)
  dev.off()
}

sum_min <- as.numeric()
sum_1se <- as.numeric()
n <- 10
nfolds <- 3
for (j in keep_network) {
  dat <-dat_wide[[j]]
  sum_min[j] <- 0
  sum_1se[j] <- 0
  for (i in 1:n){
  cvfit <- cv.glmnet(x = as.matrix(select(dat, -status)),
                   y =  as.factor(dat$status),
                   family = "binomial", 
                   type.measure = "class",
                   alpha = 0.5,
                   nfolds = nfolds)
  sum_min[j] <- sum_min[j] + cvfit$lambda.min
  sum_1se[j] <- sum_1se[j] + cvfit$lambda.1se
  }
  c(sum_min/n,sum_1se/n)
}

##after choosing optimal lambda, sensitivity&robustness check
alpha_final <-  c(0, 0.49, 0.5, 0.51, 1)
lambda_final <- c(0.2, 0.29, 0.3, 0.31, 0.4)

glmnet_res <- list ()
coeffs <- list()
for (j in keep_network){
  dat <-dat_wide[[j]]
  glmnet_res[[j]] <- glmnet(dat[-ncol(dat)],dat$status,
                family='binomial',
                alpha=0.5,
                standardize = TRUE,
                nfolds = 10)
}

coeffs <- map(glmnet_res, ~coef(.,s=lambda_final))
coeffs_df <- map(coeffs,~as.data.frame(as.matrix(.)))

for (j in keep_network){
  colnames(coeffs_df[[j]]) <- as.character(lambda_final)
}

for (j in keep_network){
  coeffs_df[[j]] <- coeffs_df[[j]][-1,]
  insig <- rowSums(coeffs_df[[j]][,-1])==0
  coeffs_df[[j]] <- coeffs_df[[j]][!insig,]
}

png('robust_lambda3T.png')
par(mfrow=c(3,2))
for (j in keep_network) {
  coeff <- coeffs_df[[j]]
  plot(1:5,coeff[1,],type = "b", lty = 2, col = 1:5,
       ylim = c(-0.05,0.05),
       ylab = "Coefficients", xlab="lambda", xaxt='n', main=j)
  axis(1, at = 1:5, labels = colnames(coeff))
  for (i in 2:nrow(coeff)) {
    points(1:5, coeff[i, ], type = "b", lty = 2, col = 1:5 )}}
dev.off()


png('robust_alpha3T.png')
par(mfrow=c(3,2))
for (j in keep_network) {
  dat <-dat_wide[[j]]
  alphacoeffs <- list()
  for (k in 1:length(alpha_final)){
  alphacoeffs[[k]] = coef(glmnet(dat[-ncol(dat)],dat$status,
                      family = "binomial", alpha = alpha_final[k], lambda = 0.3))[-1]}
 
  bind = do.call(cbind,alphacoeffs)
  plot(1:5, bind[1, ], type = "b", lty = 2, col = 1:5, 
       ylab = "Coefficients", xlab="alpha", ylim=c(-0.05, 0.05),xaxt='n',main=j)
  axis(1, at = 1:5, labels = alpha_final)
  for (i in 2:nrow(bind)) {
      points(1:5, bind[i, ], type = "b", lty = 2, col = 1:5)}
}

dev.off()