library (readr)
library (ggplot2)
require(tidyverse)

# Get the data
lcps.data.original <- utils::read.csv('https://lcps.nu/wp-content/uploads/covid-19.csv', sep =',')
#lcps.data.original[163,] <- c("10-11-2020", 603, 476, 1842, 33, 180)
# Order numbers: IC_Bedden_COVID, IC_Bedden_Non_COVID, Kliniek_Bedden, IC_Nieuwe_Opnames_COVID, Kliniek_Nieuwe_Opnames_COVID
lcps.data <- lcps.data.original %>%
  mutate(
    date = as.Date(Datum, tryFormats = c('%d-%m-%Y')),
    .before = Datum
  ) %>%
  mutate(
    Datum = NULL
  )

lcps.dailydata <- lcps.data %>%
  tail(1)
lcps.date <- lcps.dailydata[['date']]
lcps.data <- lcps.data[order(lcps.data$date),]

# Add 7-daverage.
lcps.data$IC_COVID_7daverage <- round(frollmean(lcps.data[,"IC_Bedden_COVID"],7),0)
lcps.data$IC_Non_COVID_7daverage <- round(frollmean(lcps.data[,"IC_Bedden_Non_COVID"],7),0)

# Rename values
lcps.data <- lcps.data %>%
  rename(
    Covidpatienten = IC_Bedden_COVID,
    "Niet Covidpatienten" = IC_Bedden_Non_COVID
  )

# Make data long
lcps.data_long <- pivot_longer(lcps.data, cols = (2:3), names_to = "Bed_kind", values_to = "Number_of_beds")
lcps_data_long$IC_covid_7daverage <- round(frollmean(lcps.data_long[,""],7),0)

# Filter only last period
filter.date_two_months <- Sys.Date()-40
lcps_data_long_fourweek <- filter(lcps.data_long, date > filter.date_two_months )

# IC GRAPH 40 days
IC_stacked_barchart <-  
  ggplot(data = lcps_data_long_fourweek, aes(x = date, y = Number_of_beds,fill = Bed_kind)) +
  geom_col(position = position_stack(reverse = T)) +
  geom_line(aes(y = IC_COVID_7daverage), size = 1.1, alpha = 1, linetype = 2) +
  ylim(0, 1250) +
  scale_fill_manual(values = c("#fc3929", "#3dc9f1")) + 
  bbc_style() +
  labs(subtitle = "De druk van corona op de IC")
  finalise_plot(plot_name = IC_stacked_barchart,
                source = "Bron: LCPS",
                save_filepath = "C:/Users/r.tromp/Code/covid-19/plots/IC_stacked.png",
                logo_image_path = "C:/Users/r.tromp/Code/covid-19/huisstijl/Argos_logo-02.png")


# IC graph year
filter.date_two_months <- Sys.Date()-120
lcps_data_long_august <- filter(lcps.data_long, date > filter.date_two_months )

IC_stacked_barchart_year <-  
  ggplot(data = lcps_data_long_august, aes(x = date, y = Number_of_beds,fill = Bed_kind)) +
    geom_col(position = position_stack(reverse = T)) +
    geom_line(aes(y = IC_COVID_7daverage), size = 1, alpha = 1, linetype = 2) +
    ylim(0, 1250) +
    scale_fill_manual(values = c("#fc3929", "#3dc9f1")) + 
    bbc_style() +
    labs(subtitle = "De druk van corona op de IC")
finalise_plot(plot_name = IC_stacked_barchart_year,
              source = "Bron: LCPS",
              save_filepath = "C:/Users/r.tromp/Code/covid-19/plots/IC_stacked_year.png",
              logo_image_path = "C:/Users/r.tromp/Code/covid-19/huisstijl/Argos_logo-02.png")

# # Clinic graph
# clinic_chart_2 <- ggplot(data = lcps.data, aes(x = date, y = Kliniek_Bedden)) +
#   
#   
# plot(clinic_chart_2)
# 
# # Geomcol
# clinic_chart <-
#   ggplot(data = lcps.data, aes(x = date, y = Kliniek_Bedden)) +
#   geom_col() +
#   scale_fill_manual(value = "#fc3929") +
#   bbc_style()
# plot(clinic_chart)
# 
#   
# Y as tot 1350 maken
# kleuren, bron en logo

