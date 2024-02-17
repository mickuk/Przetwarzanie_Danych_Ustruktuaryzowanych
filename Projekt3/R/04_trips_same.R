# Attach packages -------------------------------------------------------------

library("dplyr")
library("ggplot2")
library("lubridate")
library("purrr")

# Yearly number of trips between 2016-2021 with the same start and end --------

trips_year_same <- paired_tripdata %>%
  map_dfr(
    . %>%
    select(ends_with(c("at", "name"))) %>%
    mutate(
      duration = as.duration(ended_at - started_at),
      year = year(started_at)) %>%
    filter(
      duration > dminutes(5) & duration < dminutes(45),
      between(year, 2016, 2021),
      !is.na(end_station_name)
    )
  ) %>%
  group_by(year) %>%
  summarise(
    count = sum(start_station_name == end_station_name),
    fraction = count / n()
  )

ggplot(trips_year_same, aes(year, count)) +
  geom_col(fill = "#6e5871") +
  geom_label(
    aes(
      label = count,
      y = count
    ),
    colour = "white",
    fill = "#6e5871",
    fontface = "bold",
    position = position_dodge(0.9),
    show.legend = FALSE,
    vjust = -0.2
  ) +
  labs(
    title = "Yearly number of trips with the same start and end",
    x = "Year",
    y = "Count",
  ) +
  scale_x_continuous(breaks = 2016:2021)

# in percent (%)
ggplot(trips_year_same, aes(year, fraction)) +
  geom_col(fill = "#6e5871") +
  geom_label(
    aes(
      label = scales::label_percent(
        accuracy = .01
      )(fraction),
      y = fraction
    ),
    colour = "white",
    fill = "#6e5871",
    fontface = "bold",
    position = position_dodge(0.9),
    show.legend = FALSE,
    vjust = -0.2
  ) +
  labs(
    title = "Yearly number of trips with the same start and end (%)",
    x = "Year",
    y = "Percent",
  ) +
  scale_x_continuous(breaks = 2016:2021)
