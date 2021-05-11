# Runs everything
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
# setwd("C:/Users/r.tromp/Code/radio1_coronatikker")
source("daily_tikker_update.R")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("plotjes_scripts/cases_graph.R")
source("plotjes_scripts/IC_graphs.R")




