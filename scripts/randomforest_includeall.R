library(dplyr)
library(reshape2)
library(tidyr)
library(glue)
library(purrr)
library(party)
library(randomForest)

# set.seed(5234)
set.seed(123)

# TENSOR <- "3T"
TENSOR <- "7T"

dat_wide <- readRDS(file = glue("data/dat_formatted_{TENSOR}.RDS"))
colnames(dat_wide) <- make.names(colnames(dat_wide))

#wilcoxon
# dat_wide <- readRDS(file = glue("data/dat_wcfiltered_{TENSOR}.RDS"))

#Run random forest the first time and extract most important features
rf_first <- superagers_rf(dat_wide,mtry=51,ntree=10000)

saveRDS(rf_first, file = glue("data/rf_1st_res{TENSOR}.RDS"))

mdg <- importance(rf_first, type = 2)
mdg <- as.data.frame(mdg)


mdg$MeanDecreaseGini <- as.numeric(mdg$MeanDecreaseGini)
avg_mdg <- mean(mdg$MeanDecreaseGini)
sd_mdg <- sd(mdg$MeanDecreaseGini)
mdg_thresh <- avg_mdg + sd_mdg

mdg_list <- row.names(mdg)[mdg$MeanDecreaseGini > mdg_thresh]
rf_first_mdg <- subset(mdg,rownames(mdg) %in% mdg_list)
saveRDS(rf_first_mdg, file = glue("data/mdg_1strf_{TENSOR}.RDS"))

mdg_filtered <- dat_wide%>%
                 select_if(colnames(dat_wide) %in% mdg_list)%>%
                 mutate(status=dat_wide[,'status'])

saveRDS(mdg_filtered, file = glue("data/dat_mdgfiltered_{TENSOR}.RDS"))

mda <- importance(rf_first, type = 1)
mda <- as.data.frame(mda)


mda$MeanDecreaseAccuracy <- as.numeric(mda$MeanDecreaseAccuracy)
avg_mda <- mean(mda$MeanDecreaseAccuracy)
sd_mda <- sd(mda$MeanDecreaseAccuracy)
mda_thresh <- avg_mda + sd_mda

mda_list <- row.names(mda)[mda$MeanDecreaseAccuracy > mda_thresh]
rf_first_mda <- subset(mda,rownames(mda) %in% mda_list)
saveRDS(rf_first_mda, file = glue("data/mda_1strf_{TENSOR}.RDS"))

mda_filtered <- dat_wide%>%
  select_if(colnames(dat_wide) %in% mda_list)%>%
  mutate(status=dat_wide[,'status'])

saveRDS(mda_filtered, file = glue("data/dat_mdafiltered_{TENSOR}.RDS"))

#Run random forest second time
set.seed(123)
rf_second_mdg <- superagers_rf(mdg_filtered,mtry=5,ntree=5000)
plot(rf_second_mdg)
varImpPlot(rf_second_mdg,sort=TRUE,n.var=10)

saveRDS(rf_second_mdg, file = glue("data/rf_res_{TENSOR}_includemdg.RDS"))


set.seed(123)
rf_second_mda <- superagers_rf(mda_filtered,mtry=5,ntree=5000)
plot(rf_second_mda)
varImpPlot(rf_second_mda,sort=TRUE,n.var=10)

saveRDS(rf_second_mda, file = glue("data/rf_res_{TENSOR}_includemda.RDS"))


#Run random forest on wilcoxon selected subset
set.seed(123)
rf_wc <- superagers_rf(dat_filtered,mtry=4,ntree=5000)
plot(rf_wc)
varImpPlot(rf_wc,sort=TRUE,n.var=20)

saveRDS(rf_wc, file = glue("data/rfwc_res_{TENSOR}_includeall.RDS"))

