require(cowplot)
require(tidyverse)
require(rjson)
require(data.table)
require(pacman)
# library(extrafont)

pacman::p_load('dplyr', 'tidyr', 'gapminder',
               'ggplot2',  'ggalt',
               'forcats', 'R.utils', 'png', 
               'grid', 'ggpubr', 'scales',
               'bbplot')

# Data filteren voor de laatste 4 weken
all.data$date <- as.Date(all.data$date)
filter.date <- Sys.Date()-28 # Set filter date for last 4 weeks
fourweek_data <- filter(all.data, date > filter.date ) 

# data filteren voor cases
cases <- subset(fourweek_data, new.infection != 'NA')

# NIEUWE BESMETTINGEN GRAPH
cases_chart <- ggplot(data = cases, aes(x = date)) +
  geom_line(aes(y = new.infection), color = "#fc3929", size = 1.2) +
  geom_line(aes(y = positive_7daverage), color = "#3dc9f1", size = 1, alpha = 0.8, linetype = 2) +
  bbc_style() +
  labs(subtitle = 'Nieuwe besmettingen per dag') +
  theme(legend.position = "top")
#  scale_fill_manual(values = c("#1380A1", "#FAAB18"))
plot(cases_chart)

finalise_plot(plot_name = cases_chart,
              source = "Bron: RIVM",
              save_filepath = "C:/Users/r.tromp/Code/covid-19/plots/nieuwe_besmettinge.png",
              logo_image_path = "C:/Users/r.tromp/Code/covid-19/huisstijl/Argos_logo-02.png")

## IC GRAPH 1
# Data filteren voor IC-opnames

IC_chart <- ggplot(data = fourweek_data, aes(x = date)) +
  geom_line(aes(y = IC_Current), color = "#3dc9f1", size = 1.2) +
  geom_hline(yintercept=850, color = "#fc3929", size = 1.6,) +
  geom_label(aes( x = date[15], y = 760, label = "IC-capaciteit"),
             hjust = 0, 
             vjust = 0.5, 
             colour = "#555555", 
             fill = "white", 
             label.size = NA, 
             family="Helvetica", 
             size = 5) +
  geom_curve(aes(x = date[15], y = 760, xend = date[13], yend = 850),
             colour = "#555555",
             size = 0.5,
             curvature = -0.2,
             arrow = arrow(length = unit(0.03, "npc"))) +
  bbc_style() +
  labs(subtitle = 'Coronapatienten liggend op de IC')

plot(IC_chart)

finalise_plot(plot_name = IC_chart,
              source = "Bron: Stichting NICE",
              save_filepath = "C:/Users/r.tromp/Code/covid-19/plots/IC.png",
              logo_image_path = "C:/Users/r.tromp/Code/covid-19/huisstijl/Argos_logo-02.png")


# IC GRAPH NICE DATA
IC_chart <- ggplot(data = nice_by_day, aes(x = date)) +
  geom_line(aes(y = IC_Current), color = "#3dc9f1", size = 1.2) +
  geom_hline(yintercept=850, color = "#fc3929", size = 1.6,) +
  geom_label(aes( x = date[15], y = 760, label = "IC-capaciteit"),
             hjust = 0, 
             vjust = 0.5, 
             colour = "#555555", 
             fill = "white", 
             label.size = NA, 
             family="Helvetica", 
             size = 5) +
  geom_curve(aes(x = date[15], y = 760, xend = date[13], yend = 850),
             colour = "#555555",
             size = 0.5,
             curvature = -0.2,
             arrow = arrow(length = unit(0.03, "npc"))) +
  bbc_style() +
  labs(subtitle = 'Coronapatienten liggend op de IC')

plot(IC_chart)

finalise_plot(plot_name = IC_chart,
              source = "Bron: Stichting NICE",
              save_filepath = "C:/Users/r.tromp/Code/covid-19/plots/IC.png",
              logo_image_path = "C:/Users/r.tromp/Code/covid-19/huisstijl/argos_roodblauw.png")



## PREPARE IC DATA
# make a sum


# TIDY IC DATA
# lcps.data.tidy <- aggregate(lcps.data$) 

# lcps.data_long <- pivot_longer(lcps.data, cols = (2:3), names_to = "Bed_kind", values_to = "Number_of_beds")
# 
# ## IC GRAPH 2
# lcps.data_long %>% ggplot(aes(x = date, y = Bed_kind)) +
#   geom_col(position = "stack")
# 
# 
# 
# ## TESTGRAPH
# stacked_df <- gapminder %>% 
#   filter(year == 2007) %>%
#   mutate(lifeExpGrouped = cut(lifeExp, 
#                               breaks = c(0, 50, 65, 80, 90),
#                               labels = c("Under 50", "50-65", "65-80", "80+"))) %>%
#   group_by(continent, lifeExpGrouped) %>%
#   summarise(continentPop = sum(as.numeric(pop)))
# 
# #set order of stacks by changing factor levels
# stacked_df$lifeExpGrouped = factor(stacked_df$lifeExpGrouped, levels = rev(levels(stacked_df$lifeExpGrouped)))
# 
# #create plot
# stacked_bars <- ggplot(data = stacked_df, 
#                        aes(x = continent,
#                            y = continentPop,
#                            fill = lifeExpGrouped)) +
#   geom_bar(stat = "identity", 
#            position = "fill") +
#   bbc_style() +
#   scale_y_continuous(labels = scales::percent) +
#   scale_fill_viridis_d(direction = -1) +
#   geom_hline(yintercept = 0, size = 1, colour = "#333333") +
#   labs(title = "How life expectancy varies",
#        subtitle = "% of population by life expectancy band, 2007") +
#   theme(legend.position = "top", 
#         legend.justification = "left") +
#   guides(fill = guide_legend(reverse = TRUE))
# plot(stacked_bars)
# 
# # create a dataset
# specie <- c(rep("sorgho" , 3) , rep("poacee" , 3) , rep("banana" , 3) , rep("triticum" , 3) )
# condition <- rep(c("normal" , "stress" , "Nitrogen") , 4)
# value <- abs(rnorm(12 , 0 , 15))
# data <- data.frame(specie,condition,value)
# 
# # Stacked
# ggplot(data, aes(fill=condition, y=value, x=specie)) + 
#   geom_bar(position="stack", stat="identity") +
#   bbc_style()
