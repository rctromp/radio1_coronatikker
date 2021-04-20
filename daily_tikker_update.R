# setwd("C:/Users/r.tromp/Code/radio1_coronatikker/covid-19")
setwd("covid-19")

# Parse RIVM, NICE and corrections data
source("workflow/parse_lcps-data.R")
source("workflow/parse_nice-data.R")
source("workflow/parse_rivm-data.R")
source("workflow/parse_nursing-homes.R")
# source("workflow/parse_municipalities.R")
source("workflow/parse_tests.R")
source("workflow/parse_corrections.R")

Sys.setlocale("LC_TIME", "nl_NL")

## Merge RIVM, NICE and corrections data

rivm.by_day <- read.csv("data/rivm_by_day.csv")
nice.by_day <- read.csv("data-nice/nice-today.csv")
lcps.by_day <- read.csv("data/lcps_by_day.csv")
corr.by_day <- read.csv("corrections/corrections_perday.csv")
nursery.by_day <- read.csv("data/nursery_by_day.csv")
testrate.by_day <- read.csv("data-dashboards/percentage-positive-daily-national.csv")[,c("values.tested_total","values.infected","values.infected_percentage","date","pos.rate.3d.avg")]

daily_datalist <- list(rivm.by_day,nice.by_day,lcps.by_day,corr.by_day,nursery.by_day)

all.data <- Reduce(
  function(x, y, ...) merge(x, y, by="date",all.x = TRUE, ...),
  daily_datalist
)

all.data$date <- as.Date(all.data$date)
all.data <- all.data[order(all.data$date),]

write.csv(all.data, file = "data/all_data.csv",row.names = F)

#source("plot_scripts/Radio1_plots.R")
#source("plot_scripts/daily_plots.R")
#source("plot_scripts/daily_maps_plots.R")
# source("plot_scripts/IC_graphs.R")

all.data <- read.csv("data/all_data.csv")
nice.by_day <- read.csv("data/nice_by_day.csv")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

## Load values for printing
# LCPS_klinisch_two_days <- last(all.data$Kliniek_Bedden,2)
# LCPS_Verpleeg_Huidig_Toename <- LCPS_klinisch_two_days[2] - LCPS_klinisch_two_days[1]
# LCPS_IC_two_days <- last(all.data$IC_Bedden_COVID,2)
# LCPS_IC_Huidig_Toename <- LCPS_IC_two_days[2] - LCPS_IC_two_days[1]
# 
# sign.hosp.lcps <- paste0(ifelse(LCPS_Verpleeg_Huidig_Toename>=0," (+"," ("))
# sign.ic.lcps <- paste0(ifelse(LCPS_IC_Huidig_Toename>=0," (+"," ("))
# 
# Kliniek_Nieuwe_Opnames <- ifelse(is.na(last(all.data$Kliniek_Nieuwe_Opnames_COVID)),"Onbekend",last(all.data$Kliniek_Nieuwe_Opnames_COVID))
# Kliniek_Aanwezig <- ifelse(is.na(last(all.data$Kliniek_Bedden)),"Onbekend",paste0(format(last(all.data$Kliniek_Bedden),decimal.mark = ",",big.mark =".",big.interval = 3),sign.hosp.lcps,LCPS_Verpleeg_Huidig_Toename))
# IC_Nieuwe_Opnames <- ifelse(is.na(last(all.data$IC_Nieuwe_Opnames_COVID)),"Onbekend",last(all.data$IC_Nieuwe_Opnames_COVID))
# IC_Aanwezig <- ifelse(is.na(last(all.data$IC_Bedden_COVID)),"Onbekend",paste0(last(all.data$IC_Bedden_COVID),sign.ic.lcps,LCPS_IC_Huidig_Toename))
# 
# 

