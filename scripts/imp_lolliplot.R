
library(gridExtra)
library(ggplot2)
library(dplyr)

file_ext <- "png"
# This is node of supranormal importance realtive to each network
mdg_3T <- readRDS(file = glue("data/randomforest_mdg_network3T.RDS"))
# mda_3T <- readRDS(file = glue("data/randomforest_mda_network3T.RDS"))

# mdg_7T <- readRDS(file = glue("data/randomforest_mdg_network7T.RDS"))
# mda_7T <- readRDS(file = glue("data/randomforest_mda_network7T.RDS"))


# This is the importance of ~100 nodes selected by random forest, all network included
# mdg_3T <- readRDS(file =  glue("data/mdg_1strf_3T_comb.RDS"))
# mda_3T <- readRDS(file =  glue("data/mda_1strf_3T_comb.RDS"))

# mdg_7T <- readRDS(file =  glue("data/mdg_1strf_7T_comb.RDS"))
# mda_7T <- readRDS(file =  glue("data/mda_1strf_7T_comb.RDS"))

# This is the most importance node from running rf twice
# mdg_3T <- readRDS(file =  glue("data/randomforest_mdg_final3T.RDS"))
# mda_3T <- readRDS(file =  glue("data/randomforest_mda_final3T.RDS"))

# mdg_7T <- readRDS(file =  glue("data/randomforest_mdg_final7T.RDS"))
# mda_7T <- readRDS(file =  glue("data/randomforest_mda_final7T.RDS"))

plot_mdg_3T <- lapply(unique(mdg_3T$network), function(x) {
  data <- mdg_3T[mdg_3T$network == x, ]
  p <- ggplot(data, aes(x = reorder(region_stem, mean_importance), y = mean_importance)) +
    geom_point(color = "#69b3a2", size = 3) +
    geom_segment(aes(xend = region_stem, yend = 0), linetype = "dashed", color = "#69b3a2", size = 0.8) +
    coord_flip() +
    theme_bw() +
    labs(title = x, x = "Region", y = "Mean Decrease Gini")
  p
})

plot_mda_3T <- lapply(unique(mda_3T$network), function(x) {
  data <- mda_3T[mda_3T$network == x, ]
  p <- ggplot(data, aes(x = reorder(region_stem, mean_importance), y = mean_importance)) +
    geom_point(color = "#69b3a2", size = 3) +
    geom_segment(aes(xend = region_stem, yend = 0), linetype = "dashed", color = "#69b3a2", size = 0.8) +
    coord_flip() +
    theme_bw() +
    labs(title = x, x = "Region", y = "Mean Decrease Accuracy")
  p
})

png("output/mdg_lolliplot_3T_final.png",width = 960, height = 720)
grid.arrange(grobs = plot_mdg_3T, nrow = 3, ncol = 4)
dev.off()

png("output/mda_lolliplot_3T_final.png",width = 960, height = 720)
grid.arrange(grobs = plot_mda_3T, nrow = 3, ncol = 4)
dev.off()

plot_mdg_7T <- lapply(unique(mdg_7T$network), function(x) {
  data <- mdg_7T[mdg_7T$network == x, ]
  p <- ggplot(data, aes(x = reorder(region_stem, mean_importance), y = mean_importance)) +
    geom_point(color = "#69b3a2", size = 3) +
    geom_segment(aes(xend = region_stem, yend = 0), linetype = "dashed", color = "#69b3a2", size = 0.8) +
    coord_flip() +
    theme_bw() +
    labs(title = x, x = "Region", y = "Mean Decrease Gini")
  p
})

plot_mda_7T <- lapply(unique(mda_7T$network), function(x) {
  data <- mda_7T[mda_7T$network == x, ]
  p <- ggplot(data, aes(x = reorder(region_stem, mean_importance), y = mean_importance)) +
    geom_point(color = "#69b3a2", size = 3) +
    geom_segment(aes(xend = region_stem, yend = 0), linetype = "dashed", color = "#69b3a2", size = 0.8) +
    coord_flip() +
    theme_bw() +
    labs(title = x, x = "Region", y = "Mean Decrease Accuracy")
  p
})

png("output/mdg_lolliplot_7T_final.png",width = 960, height = 720)
grid.arrange(grobs = plot_mdg_7T, nrow = 3, ncol = 4)
dev.off()

png("output/mda_lolliplot_7T_final.png",width = 960, height = 720)
grid.arrange(grobs = plot_mda_7T, nrow = 3, ncol = 4)
dev.off()


##plot on a grid

mdg3T <-
  ggplot(data = mdg_3T, aes(x = reorder(region_stem, mean_mdg), y = mean_mdg)) +
  geom_segment(aes(xend = region_stem, yend = 0), linewidth = 1, color="darkgrey") +
  geom_point(color = "blue", size = 3) +
  xlab(label = "") +
  facet_grid(unlist(network)~.) +
  ylab("Mean Decrease Gini") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        legend.position = "none") +
  ylim(0, 1.25) +
  theme(plot.margin = unit(c(0.3,0.3,0.3,1.5), "cm"))

png("output/mdg_lolliplot_3T_merged_network.png", width = 720, height = 480)
mdg3T
dev.off()

mda3T <-
  ggplot(data = mda_3T, aes(x = reorder(region_stem, mean_importance), y = mean_importance)) +
  geom_segment(aes(xend = region_stem, yend = 0), linewidth = 1, color="darkgrey") +
  geom_point(color = "blue", size = 3) +
  xlab(label = "") +
  facet_grid(unlist(network)~.) +
  ylab("Mean Decrease Accuracy") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        legend.position = "none") +
  ylim(0, 15) +
  theme(plot.margin = unit(c(0.3,0.3,0.3,1.5), "cm"))

png("output/mda_lolliplot_3T_merged_final.png", width = 960, height = 720)
mda3T
dev.off()


mdg7T <-
  ggplot(data = mdg_7T, aes(x = reorder(region_stem, mean_importance), y = mean_importance)) +
  geom_segment(aes(xend = region_stem, yend = 0), linewidth = 1, color="darkgrey") +
  geom_point(color = "blue", size = 3) +
  xlab(label = "") +
  facet_grid(unlist(network)~.) +
  ylab("Mean Decrease Gini") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        legend.position = "none") +
  ylim(0, 0.5) +
  theme(plot.margin = unit(c(0.3,0.3,0.3,1.5), "cm"))

png("output/mdg_lolliplot_7T_merged_final.png", width = 960, height = 720)
mdg7T
dev.off()

mda7T <-
  ggplot(data = mda_7T, aes(x = reorder(region_stem, mean_importance), y = mean_importance)) +
  geom_segment(aes(xend = region_stem, yend = 0), linewidth = 1, color="darkgrey") +
  geom_point(color = "blue", size = 3) +
  xlab(label = "") +
  facet_grid(unlist(network)~.) +
  ylab("Mean Decrease Accuracy") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 8),
        legend.position = "none") +
  ylim(0, 15) +
  theme(plot.margin = unit(c(0.3,0.3,0.3,1.5), "cm"))

png("output/mda_lolliplot_7T_merged_final.png", width = 960, height = 720)
mda7T
dev.off()


