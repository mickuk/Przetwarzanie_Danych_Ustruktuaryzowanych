# Attach packages -------------------------------------------------------------

library("dplyr")
library("forcats")
library("ggplot2")
library("lubridate")

# Yearly number of trips by gender between 2016-2020 --------------------------

trips_year_gender <- old_tripdata %>%
  select(started_at, gender) %>%
  mutate(
    year = year(started_at),
    gender = fct_relevel(gender,
      "male", "female", "unknown"
    )
  ) %>%
  filter(between(year, 2016, 2020)) %>%
  count(year, gender, name = "count") %>%
  group_by(year) %>%
  mutate(fraction = count / sum(count)) %>%
  ungroup()

ggplot(trips_year_gender, aes(year,count, fill = gender)) +
  geom_col(position = "dodge2") +
  geom_label(
    aes(
      label = count,
      y = count
    ),
    colour = "white",
    fontface = "bold",
    position = position_dodge(0.9),
    show.legend = FALSE,
    vjust = -0.2
  ) +
  labs(
    title = "Yearly number of trips by gender",
    x = "Year",
    y = "Count",
    fill = "Gender"
  ) +
  scale_fill_manual(
    values = c(
      male = "#355995",
      female = "#9c356c",
      unknown = "#f58442"
    )
  )

# in percents (%)
ggplot(trips_year_gender, aes(year, fraction, fill = gender)) +
  geom_col(position = "dodge2") +
  geom_label(
    aes(
      label = scales::label_percent(
        accuracy = .01
      )(fraction),
      y = fraction
    ),
    colour = "white",
    fontface = "bold",
    position = position_dodge(0.9),
    show.legend = FALSE,
    vjust = -0.2
  ) +
  labs(
    title = "Yearly number of trips by gender (%)",
    x = "Year",
    y = "Percent",
    fill = "Gender"
  ) +
  scale_fill_manual(
    values = c(
      male = "#355995",
      female = "#9c356c",
      unknown = "#f58442"
    )
  ) +
  scale_y_continuous(labels = scales::label_percent())
