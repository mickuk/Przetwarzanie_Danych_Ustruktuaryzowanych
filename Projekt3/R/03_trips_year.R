# Attach packages -------------------------------------------------------------

library("dplyr")
library("ggplot2")
library("lubridate")
library("purrr")

# Yearly number of trips between 2016-2021 ------------------------------------

trips_year <- paired_tripdata %>%
  map_dfr(
    . %>%
      select(started_at) %>%
      mutate(year = year(started_at)) %>%
      filter(between(year, 2016, 2021))
  ) %>%
  count(year, name = "count")

ggplot(trips_year, aes(year, count)) +
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
    title = "Yearly number of trips",
    x = "Year",
    y = "Count",
  ) +
  scale_x_continuous(breaks = 2016:2021)
