# Attach packages -------------------------------------------------------------

library("dplyr")
library("forcats")
library("ggplot2")
library("lubridate")

# Number of trips by type of bike between 2021-02 and 2022-04 -----------------

# trips_rideable <- new_tripdata %>%
#   select(started_at, rideable_type) %>%
#   mutate(year = floor_date(started_at, "year")) %>%
#   count(rideable_type, name = "trips")
#
# ggplot(trips_rideable, aes(rideable_type, trips)) +
#   geom_col(fill = "#6e5871")

# Monthly number of trips by type of bike between 2021-02 and 2022-04 ---------

trips_rideable_month <- new_tripdata %>%
  select(started_at, rideable_type) %>%
  mutate(
    month = floor_date(started_at, "month"),
    rideable_type = fct_relevel(rideable_type,
      "electric_bike", "classic_bike", "docked_bike"
    )
  ) %>%
  count(rideable_type, month, name = "trips")

ggplot(trips_rideable_month) +
  geom_col(aes(month, trips, fill = rideable_type)) +
  scale_fill_manual(values = c(
      docked_bike = "black",
      classic_bike = "#127820",
      electric_bike = "#145cd9"
    )
  ) +
  labs(
    title = "Monthly number of trips by type of bike",
    x = "Month",
    y = "Count",
    fill = "Type of bike"
  ) +
  scale_x_datetime(
    date_labels = "%b %Y",
    date_breaks = "month",
    guide = guide_axis(angle = 45)
  )

# Daily number of trips by type of bike between 2021-02 and 2022-04 -----------

trips_rideable_day <- new_tripdata %>%
  select(started_at, rideable_type) %>%
  mutate(day = floor_date(started_at, "day")) %>%
  count(rideable_type, day, name = "trips")

ggplot(trips_rideable_day) +
  geom_line(aes(day, trips, color = rideable_type)) +
  scale_color_manual(values = c(
      docked_bike = "black",
      classic_bike = "#127820",
      electric_bike = "#145cd9"
    )
  ) +
  labs(
    title = "Daily number of trips by type of bike",
    x = "Day",
    y = "Count",
    colour = "Type of bike"
  ) +
  scale_x_datetime(
    date_labels = "%b %Y",
    date_breaks = "month",
    guide = guide_axis(angle = 45)
  )
