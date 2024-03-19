library(purrr)
library(glue)
library(reshape2)
library(dplyr)
library(tidyr)


# TENSOR <- "3T"
 TENSOR <- "7T"


#dat_list <- readRDS(file = glue("data/dat_list_{TENSOR}_n.RDS"))
dat_list <- readRDS(file = glue("data/dat_list_{TENSOR}.RDS"))


#Transform to wide format
dat_wide <- map(dat_list, ~wide_format(.x))

dat_bind <- do.call(cbind,dat_wide)
factor_cols <- dat_bind %>%
  select_if(is.factor) %>%
  names()
for (i in factor_cols[-length(factor_cols)]){
  dat_bind <- select(dat_bind,-i)
}
colnames(dat_bind)[ncol(dat_bind)] <- "status"


saveRDS(dat_bind, file = glue("data/dat_formatted_{TENSOR}.RDS"))
