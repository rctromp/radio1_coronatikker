# Code that calculates the infections per Veiligheidsregio. 

library(dplyr)
library(tidyverse)
library(readxl)

## GGDS
geoUrl <- "https://geodata.nationaalgeoregister.nl/cbsgebiedsindelingen/wfs?request=GetFeature&service=WFS&version=2.0.0&typeName=cbs_ggdregio_2019_gegeneraliseerd&outputFormat=json"
fileName <- "misc/maps/ggdgrenzen2020.geojson" # File for GGD map
ggdgrenzen <- geojson_read(fileName, what = "sp") # Load GGD map

temp = list.files(path = "data-rivm/casus-datasets/",pattern="*.csv", full.names = T) ## Pull names of all available datafiles 
dat.today <- read.csv(last(temp)) ## Case file today
dat.yesterday <- read.csv(temp[length(temp)-1]) ## Case file week ago
dat.weekago <- read.csv(temp[length(temp)-7]) ## Case file week ago
dat.week <- read.csv(temp[length(temp)])

ggd.cases.today <- as.data.frame(table(dat.today$Municipal_health_service)) ## Cumulative cases per GGD
ggd.cases.yesterday <- as.data.frame(table(dat.yesterday$Municipal_health_service)) ## Cumulative cases per GGD
ggd.cases.weekago <- as.data.frame(table(dat.weekago$Municipal_health_service)) ## Cumulative cases per GGD - week ago

ggd_datalist <- list(as.data.frame(table(dat.today$Municipal_health_service)), as.data.frame(table(dat.yesterday$Municipal_health_service)),as.data.frame(table(dat.weekago$Municipal_health_service)))

ggd.data <- Reduce(
  function(x, y, ...) merge(x, y, by="Var1", ...),
  ggd_datalist
)

colnames(ggd.data) <- c("statnaam","cases_today","cases_yesterday","cases_lastweek")
ggd.data$statnaam <- as.character(ggd.data$statnaam)

ggd.data$statnaam <- recode(ggd.data$statnaam, "GGD FryslÃ¢n" = "GGD Fryslân",
                            "GGD Zuid Limburg" = "GGD Zuid-Limburg",
                            "GGD Brabant Zuid-Oost " = "GGD Brabant-Zuidoost",
                            "GGD Hollands Midden" = "GGD Hollands-Midden",
                            "GGD Limburg Noord" = "GGD Limburg-Noord",
                            "GGD Zaanstreek-Waterland" = "GGD Zaanstreek/Waterland",
                            "GGD West Brabant" = "GGD West-Brabant",
                            "GGD Rotterdam Rijnmond" = "GGD Rotterdam-Rijnmond",
                            "GGD regio Utrecht" = "GGD Regio Utrecht",
                            "GGD Gelderland-Midden" = "Veiligheids- en Gezondheidsregio Gelderland-Midden",
                            "GGD Hollands Noorden" = "GGD Hollands-Noorden",
                            "GGD Noord en Oost Gelderland" = "GGD Noord- en Oost-Gelderland")


ggd.data <- ggd.data[order(ggd.data$statnaam),]
ggd.data$ID <- seq.int(nrow(ggd.data))

ggd.population <- read.csv("misc/ggds-population.csv")
ggd.data <- merge(ggd.data,ggd.population[,c("ID","population")],by = "ID", all=TRUE)

ggd.data$toename.vandaag <- ggd.data$cases_today - ggd.data$cases_yesterday
ggd.data$toename.vandaag <- ifelse((ggd.data$cases_today - ggd.data$cases_yesterday)<0,0,ggd.data$cases_today - ggd.data$cases_yesterday)

ggd.data$toename.week <- ggd.data$cases_today - ggd.data$cases_lastweek

ggd.data$`Besmettingen (sinds gisteren)` <- ggd.data$toename.vandaag/ggd.data$population*100000
ggd.data$`Besmettingen (7 dagen)` <- ggd.data$toename.week/ggd.data$population*100000


# calculate average cases




## prepare BCO dataframe
bco_fte <- read_excel("C:/Users/r.tromp/OneDrive - VPRO/Corona/BCO/bco_fte.xlsx")
bco_fte$'BCO FTE totaal' <- round(bco_fte$`BCO FTE totaal`, digits = 0)
bco_fte$'BCO FTE 30 sep' <- round(bco_fte$'BCO FTE 30 sep', digits = 0)



# assumptions
hours_per_case <- 11 # GGDHORS zegt 8 - 12, De jonge zei 12.
fte_in_hours <- 36
days <- 7

# # add BCO per day
# ggd.data$bco_daily[ggd.data$statnaam == "GGD Groningen"] <- 10
# 
# # add BCO FTE
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Groningen"] <- 15.5
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Drenthe"] <- 21.8
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD IJsselland"] <- 31.1
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Regio Twente"] <- 12.4
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Zuid-Limburg"] <- 50
# ggd.data$bco_fte-sept[ggd.data$statnaam == "GGD Kennemerland"] <- 30
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Gelderland-Zuid"] <- 40
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Flevoland"] <- 23
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Regio Twente"] <- 12.4
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Gooi en Vechtstreek"] <- 15
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Regio Utrecht"] <- 50
# ggd.data$bco_fte_sept[ggd.data$statnaam == "Dienst Gezondheid & Jeugd ZHZ"] <- NA
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Amsterdam"] <- NA
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Brabant-Zuidoost"] <- 42
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Fryslân"] <- 40
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Haaglanden"] <- NA
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Hart van Brabant"] <- 52
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Hollands-Midden"] <- 31
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Hollands-Noorden"] <- NA
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Limburg-Noord"] <- 29.5
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Noord- en Oost-Gelderland"] <- NA
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Rotterdam-Rijnmond"] <- NA
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD West-Brabant" ] <- NA
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Zaanstreek/Waterland"] <- NA
# ggd.data$bco_fte_sept[ggd.data$statnaam == "GGD Zeeland"] <- NA
# ggd.data$bco_fte_sept[ggd.data$statnaam == "Veiligheids- en Gezondheidsregio Gelderland-Midden"] <- NA

#merge
ggd.data = merge(x = ggd.data, y = bco_fte, by.x = "statnaam", by.y = "GGD", all.x =TRUE)


# calculate max BCO a GGD can do per day in cases
bco_max_sept <- round((((ggd.data$bco_fte * fte_in_hours) / days) / hours_per_case), digits=0)
ggd.data$bco_max_sept <- bco_max_sept
bco_max_okt <- round((((ggd.data$"BCO FTE 30 sep" * fte_in_hours) / days) / hours_per_case), digits=0)
ggd.data$bco_max_okt <- bco_max_okt

# export
write.csv(ggd.data, "bco\\bco_2.csv", row.names = FALSE)






