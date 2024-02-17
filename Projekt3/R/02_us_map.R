# Attach packages -------------------------------------------------------------

library("dplyr")
library("forcats")
library("ggplot2")
library("rnaturalearth")
library("sf")

# New Jersey & New York on US map ---------------------------------------------

jc_coords <- tibble(
  city = "Jersey City",
  lat = -74.064722,
  lng = 40.711389
)

us <- ne_states(
  country = 'United States of America',
  returnclass = "sf",
)

us_nyc_jc <- us %>%
  mutate(
    name = as_factor(name) %>%
      fct_other(
        keep = c("New York", "New Jersey"),
        other_level = "other"
      )
  )

ggplot(us_nyc_jc) +
  geom_sf(aes(fill = name)) +
  coord_sf(
     xlim = c(-125, -65),
     ylim = c(25, 50)
  ) +
  labs(
    title = "New Jersey & New York states on US map",
    fill = "States",
    x = "Longitude",
    y = "Latitude"
  ) +
  scale_fill_manual(
    values = c(
      "New York" = "grey70",
      "New Jersey" = "#deb952",
      "other" = "grey90"
    )
  ) +
  geom_point(
    data = jc_coords,
    mapping = aes(lat, lng)
  ) +
  geom_label(
    data = jc_coords,
    aes(
      label = city,
      x = lat,
      y = lng
    ),
    colour = "white",
    fill = scales::hue_pal()(1),
    fontface = "bold",
    position = position_dodge(0.9),
    show.legend = FALSE,
    hjust = -0.1,
    vjust = 1.1
  )
