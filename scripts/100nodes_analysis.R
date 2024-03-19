
#It accepts the list of most important nodes from first run of random forest and combine it
library(dplyr)
library(purrr)
# set.seed(5234)
set.seed(123)
#? set.seed

## select tensor data

TENSOR <- "3T"
# TENSOR <- "7T"



dat_list <- readRDS(file = glue("data/dat_list_{TENSOR}.RDS"))
mdg <- readRDS(file = glue("data/mdg_1strf_{TENSOR}.RDS"))

dat_wide <- map(dat_list,~wide_format(.x))

nodes <- rownames(mdg)
network <- list()
region <- list()
for (i in 1:length(nodes)){
  string <- nodes[i]
  split_string <- strsplit(string, ".", fixed = TRUE)[[1]]
  network[i] <- split_string[1]
  region[i] <- paste(split_string[-1], collapse = "_")
}

out <- cbind(network,region, mdg$MeanDecreaseGini)
out <- as.data.frame(out)
names(out)[3] <- "importance"
out$importance <-as.numeric(out$importance)


counts <-out %>%
  count(network)
counts <- as.data.frame(counts)
counts$ratio <- counts$n/length(out$network)

ncol <- list()
for (i in 1:length(dat_wide)){
  ncol[i] <- ncol(dat_wide[[i]])
}

counts$og <- ncol
counts$og <- as.numeric(counts$og)
counts$expected <- counts$og/sum(counts$og)

counts3T <- counts
counts7T <- counts

#observed_table <- matrix(c( 7, 12, 12, 10,  6 , 8 ,22 , 1 ,12 ,10, 2,
 #                           120, 122, 118, 126,  36,  94, 101, 141, 109,  95,  68), 
#                            nrow = 2, ncol = 11, byrow = T)
observed_table <- matrix(c( 4 ,11 , 7 ,25 , 9,  7, 12, 15,  6 ,11,  4,
                             123, 123, 123, 111 , 33,  95, 111, 127, 115 , 94 , 66), 
                          nrow = 2, ncol = 11, byrow = T)
rownames(observed_table) <- c('Important', 'Not')
colnames(observed_table) <- names(dat_wide)
observed_table

X <- chisq.test(observed_table)

res <-readRDS(file=glue("data/rf_1st_res{TENSOR}.RDS"))
mdg <- importance(res, type = 2)
mdg <- as.data.frame(mdg)


mdg$MeanDecreaseGini <- as.numeric(mdg$MeanDecreaseGini)
avg_mdg <- mean(mdg$MeanDecreaseGini)
sd_mdg <- sd(mdg$MeanDecreaseGini)
mdg_thresh <- avg_mdg + sd_mdg

mdg_list <- row.names(mdg)[mdg$MeanDecreaseGini > mdg_thresh]
rf_first_mdg <- subset(mdg,rownames(mdg) %in% mdg_list)
mdg_new <- mutate(mdg, signif = ifelse(rownames(mdg) %in% mdg_list, "important", "not important"))
nodes <- rownames(mdg_new)
network <- list()
region <- list()
for (i in 1:length(nodes)){
  string <- nodes[i]
  split_string <- strsplit(string, ".", fixed = TRUE)[[1]]
  network[i] <- split_string[1]
  region[i] <- paste(split_string[-1], collapse = "_")
}
tab <- cbind(network,region, mdg_new$MeanDecreaseGini,mdg_new$signif)

tab <- as.data.frame(tab)
ggplot(tab,aes(x = reorder(region,V3), y=V3,
               fill=V4)) +
  xlab("ROI") + ylab("mdg")+ 
  geom_bar(stat = "identity")+
  facet_grid(unlist(network)~.) +
  theme(legend.position = "none")+
  scale_fill_manual(values=c("blue", "red"))+
  theme_update(axis.ticks.x = element_blank(),
               axis.text.x = element_blank())
