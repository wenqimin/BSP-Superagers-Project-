
# using the results of glmnet
# model fits
# model performance statistics and plots


library(caret)
library(dplyr)
library(knitr)
library(reshape2)


################
# read in data #
################

res_3T <- readRDS("data/elasticnet_res_glmnet_3T.RDS")
res_7T <- readRDS("data/elasticnet_res_glmnet_7T.RDS")
#? og code stored this in data/final

dat_list_3T <- readRDS("data/dat_list_3T_n.RDS")
dat_list_7T <- readRDS("data/dat_list_7T_n.RDS")

NETWORK_NAMES <- names(res_7T)
num_networks <- length(NETWORK_NAMES)


#########
# stats #
#########

stat_res <- list()

for (i in seq_len(num_networks)) {
  
  stat_res[["3T"]][[i]] <-
    fit_stats(dat_list_3T[[i]],
              res_3T[[i]],
              glmnet = TRUE, s = 0.11)
  
  stat_res[["7T"]][[i]] <-
    fit_stats(dat_list_7T[[i]],
              res_7T[[i]],
              glmnet = TRUE, s = 0.11)
}

names(stat_res[["3T"]]) <- NETWORK_NAMES
names(stat_res[["7T"]]) <- NETWORK_NAMES

save(stat_res, file = "data/predict_glmnet_output.RData")


#########
# plots #
#########

# x11()
png("output/glmnet_scatterplot_3T.png")
par(mfrow = c(2,3))

for (i in 1:num_networks) {
  plot(stat_res$`3T`[[i]]$obs_status,
       stat_res$`3T`[[i]]$ppred[, 1],
       ylim = c(0,1),
       xaxt = "n",
       main = names(stat_res$`3T`)[i],
       xlab = "Observed status",
       ylab = "Model probablity superager")
  axis(1, at = c(1,2), labels = c("Control", "Superager"))
  abline(lm(stat_res$`3T`[[i]]$ppred[, 1] ~ stat_res$`3T`[[i]]$obs_status))
}
dev.off()

# x11()
png("output/glmnet_scatterplot_7T.png")
par(mfrow = c(2,3))

for (i in 1:num_networks) {
  plot(stat_res$`7T`[[i]]$obs_status,
       stat_res$`7T`[[i]]$ppred[, 1],
       ylim = c(0,1),
       xaxt = "n",
       main = names(stat_res$`7T`)[i],
       xlab = "Observed status",
       ylab = "Model probablity superager")
  axis(1, at = c(1,2), labels = c("Control", "Superager"))
  abline(lm(stat_res$`7T`[[i]]$ppred[, 1] ~ stat_res$`7T`[[i]]$obs_status))
}
dev.off()

## single plot for 3T and 7T
## 3T: blue, 7T: red

# png("output/rgn_scatterplot_3T_7T.png")
# tiff("output/rgn_scatterplot_3T_7T.tiff", res=300,  width = 8, height = 8, units = 'in')
pdf("output/glmnet_scatterplot_3T_7T.pdf")
par(mfrow = c(2,3))

for (i in 1:num_networks) {
  plot(x = stat_res$`3T`[[i]]$obs_status + rnorm(n = 31, 0, 0.04),
       y = stat_res$`3T`[[i]]$ppred[, 1],
       ylim = c(0,1),
       xaxt = "n",
       main = gsub("_", " ", names(stat_res$`3T`)[i]),
       xlab = "Observed status",
       ylab = "Model probablity superager",
       col = "blue",
       pch = 19)
  axis(1, at = c(1,2), labels = c("Control", "Superager"))
  abline(lm(stat_res$`3T`[[i]]$ppred[, 1] ~ stat_res$`3T`[[i]]$obs_status), col = "blue")
  
  points(stat_res$`7T`[[i]]$obs_status + rnorm(n = 21, 0, 0.04),
         stat_res$`7T`[[i]]$ppred[, 1],
         ylim = c(0,1),
         xaxt = "n",
         xlab = "Observed status",
         ylab = "Model probablity superager",
         col = "red",
         pch = 19)
  axis(1, at = c(1,2), labels = c("Control", "Superager"))
  abline(lm(stat_res$`7T`[[i]]$ppred[, 1] ~ stat_res$`7T`[[i]]$obs_status), col = "red")
}

# plot(1, type = "n", axes=FALSE, xlab="", ylab="")
# legend(x = "top", bty = "n",
#        legend = c("3T", "7T"),
#        col = c("blue", "red"), lwd=2, cex=1, horiz = FALSE)
dev.off()
