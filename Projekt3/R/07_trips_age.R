# Attach packages -------------------------------------------------------------

library("dplyr")
library("forcats")
library("ggplot2")
library("lubridate")
library("purrr")

# Yearly number of trips by age between 2016-2020 -----------------------------

trips_year_age <- old_tripdata %>%
  select(started_at, birth_year) %>%
  mutate(
    year = year(started_at),
    age = year - birth_year,
  ) %>%
  filter(
    between(year, 2016, 2020),
    is.na(age) | between(age, 16, 80)
  ) %>%
  mutate(
    age_bin = cut(age,
      breaks = seq(15, 80, by = 5)
    ) %>%
    fct_explicit_na("unknown") %>%
    fct_relevel("unknown")
  ) %>%
  count(year, age_bin, name = "count") %>%
  group_by(year) %>%
  mutate(fraction = count / sum(count)) %>%
  ungroup()

ggplot(trips_year_age, aes(age_bin, count, fill = age_bin)) +
  facet_wrap(~ year, scales = "free") +
  geom_col() +
  coord_flip() +
  geom_label(
    aes(
      label = count,
      y = count
    ),
    colour = "white",
    fontface = "bold",
    position = position_dodge(0.9),
    show.legend = FALSE,
    size = 3,
    hjust = -0.1
  ) +
  labs(
    title = "Yearly number of trips by age",
    x = NULL,
    y = "Count",
    fill = "Age"
  ) +
  guides(fill = guide_legend(reverse = TRUE)) +
  scale_fill_manual(
    values = c(
      "grey50",
      scales::hue_pal()(13)
    )
  ) +
  scale_x_discrete(
    breaks = NULL,
    drop = FALSE
  ) +
  scale_y_continuous(
    breaks = seq(0, 120000, by = 20000),
    limits = c(0, 120000),
  )

# in percent (%)
ggplot(trips_year_age, aes(age_bin, fraction, fill = age_bin)) +
  facet_wrap(~ year, scales = "free") +
  geom_col() +
  coord_flip() +
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
    size = 3,
    hjust = -0.1
  ) +
  guides(fill = guide_legend(reverse = TRUE)) +
  labs(
    title = "Yearly number of trips by age (%)",
    x = NULL,
    y = "Percent",
    fill = "Age"
  ) +
  scale_fill_manual(
    values = c(
      "grey50",
      scales::hue_pal()(13)
    )
  ) +
  scale_x_discrete(
    drop = FALSE,
    breaks = NULL
  ) +
  scale_y_continuous(
    breaks = seq(0, 0.3, by = 0.05),
    labels = scales::label_percent(),
    limits = c(0, 0.3),
  )
