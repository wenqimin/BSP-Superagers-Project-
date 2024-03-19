# coefficients bar plot
# glmnet output


library(ggplot2)
library(dplyr)

file_ext <- "png"
# file_ext <- "tiff"

out_tab_3T <- read.csv(file = "data/elasticnet_out2_glmnet_3T.csv")
out_tab_7T <- read.csv(file = "data/elasticnet_out2_glmnet_7T.csv")

# remove intercepts
plot_dat_3T <- out_tab_3T[out_tab_3T$region != "(Intercept)", ]
plot_dat_7T <- out_tab_7T[out_tab_7T$region != "(Intercept)", ]

plot3T <-
  ggplot(data = plot_dat_3T) +
  geom_col(aes(x = region, y = value, fill = {value > 0})) + #' fill = network)) +
  xlab(label = "") +
  # facet_wrap(~network) +
  facet_grid(network~.) +
  ylab("Coefficient") +
  theme_bw() +
  ylim(-0.08, 0.15) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")
plot3T

plot7T <-
  ggplot(data = plot_dat_7T) +
  geom_col(aes(x = region, y = value, fill = {value > 0})) + #' fill = network)) +
  xlab(label = "") +
  # facet_wrap(~network) +
  facet_grid(network~.) +
  ylab("Coefficient") +
  theme_bw() +
  ylim(-0.08, 0.15) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")
plot7T

ggsave(
  filename = paste0("output/coeff_bar_plot2_3T.", file_ext),
  plot = plot3T, width = 10, height = 10, dpi = 640)

ggsave(
  filename = paste0("output/coeff_bar_plot2_7T.", file_ext),
  plot = plot7T, width = 10, height = 10,  dpi = 640)


######################
# combine regions
# after model fit

comb_3T <-
  plot_dat_3T |>
  mutate(region_stem = gsub("\\_\\d*$", "", region)) |>
  group_by(region_stem, network) |>
  summarise(mean_value = mean(value)) |>
  ungroup() |>
  mutate(or = exp(mean_value))

comb_7T <-
  plot_dat_7T |>
  mutate(region_stem = gsub("\\_\\d*$", "", region)) |>
  group_by(region_stem, network) |>
  summarise(mean_value = mean(value)) |>
  ungroup() |>
  mutate(or = exp(mean_value))


plot3T <-
  ggplot(data = comb_3T) +
  geom_col(aes(x = region_stem, y = mean_value, fill = {mean_value > 0})) +
  xlab(label = "") +
  facet_grid(network~.) +
  ylab("Coefficient") +
  ylim(-0.08, 0.12) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
        legend.position = "none") +
  theme(plot.margin = unit(c(0.5,0.5,0.5,1.5), "cm"))

plot3T

plot7T <-
  ggplot(data = comb_7T) +
  geom_col(aes(x = region_stem, y = mean_value, fill = {mean_value > 0})) +
  xlab(label = "") +
  facet_grid(network~.) +
  ylab("Coefficient") +
  ylim(-0.08, 0.12) +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
        legend.position = "none") +
  theme(plot.margin = unit(c(0.5,0.5,0.5,1.5), "cm"))

plot7T

ggsave(
  filename = paste0("output2/coeff_bar_plot_3T_comb_after.", file_ext),
  plot = plot3T, width = 10, height = 10, dpi = 640)

ggsave(
  filename = paste0("output2/coeff_bar_plot_7T_comb_after.", file_ext),
  plot = plot7T, width = 10, height = 10,  dpi = 640)

write.csv(comb_3T, file = "data/comb_3T.csv")
write.csv(comb_7T, file = "data/comb_7T.csv")


# odds-ratios

lollipop3T <-
  ggplot(data = comb_3T) +
  geom_segment(aes(x = region_stem, xend = region_stem, y = 1, yend = or), linewidth = 1.5, color="darkgrey") +
  geom_point(aes(x = region_stem, y = or, col = {or > 1}), size = 4) +
  xlab(label = "") +
  facet_grid(network~.) +
  ylab("OR") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
        legend.position = "none") +
  scale_y_continuous(breaks = c(0.9, 0.95, 1, 1.05, 1.1)) +
  ylim(0.90, 1.11) +
  theme(plot.margin = unit(c(0.5,0.5,0.5,1.5), "cm"))

lollipop3T

lollipop7T <-
  ggplot(data = comb_7T) +
  geom_segment(aes(x = region_stem, xend = region_stem, y = 1, yend = or), linewidth = 1.5, color="darkgrey") +
  geom_point(aes(x = region_stem, y = or, col = {or > 1}), size = 4) +
  xlab(label = "") +
  facet_grid(network~.) +
  ylab("OR") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 12),
        legend.position = "none") +
  scale_y_continuous(breaks = c(0.95, 1, 1.05, 1.1)) +
  ylim(0.90, 1.11) +
  theme(plot.margin = unit(c(0.5,0.5,0.5,1.5), "cm"))

lollipop7T

ggsave(
  filename = paste0("output/lollipop2_3T_comb_after.", file_ext),
  plot = lollipop3T, width = 10, height = 10, dpi = 640)

ggsave(
  filename = paste0("output/lollipop2_7T_comb_after.", file_ext),
  plot = lollipop7T, width = 10, height = 10,  dpi = 640)

######################
# combine regions
# before model fit

out_tab_3T <- read.csv(file = "data/elasticnet_out_glmnet_comb_regn_3T.csv")
out_tab_7T <- read.csv(file = "data/elasticnet_out_glmnet_comb_regn_7T.csv")

# remove intercepts
plot_dat_3T <- out_tab_3T[out_tab_3T$region != "(Intercept)", ]
plot_dat_7T <- out_tab_7T[out_tab_7T$region != "(Intercept)", ]


plot3T <-
  ggplot(data = plot_dat_3T) +
  geom_col(aes(x = region, y = value, fill = {value > 0})) +
  xlab(label = "") +
  facet_grid(network~.) +
  ylab("Coefficient") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")

plot7T <-
  ggplot(data = plot_dat_7T) +
  geom_col(aes(x = region, y = value, fill = {value > 0})) +
  xlab(label = "") +
  facet_grid(network~.) +
  ylab("Coefficient") +
  theme_bw() +
  theme(axis.text.x = element_text(angle = 45, hjust = 1),
        legend.position = "none")

ggsave(
  filename = paste0("output/coeff_bar_plot_3T_comb_before.", file_ext),
  plot = plot3T, width = 10, height = 10, dpi = 640)

ggsave(
  filename = paste0("output/coeff_bar_plot_7T_comb_before.", file_ext),
  plot = plot7T, width = 10, height = 10,  dpi = 640)
