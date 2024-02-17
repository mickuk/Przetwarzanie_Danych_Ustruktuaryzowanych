# Attach packages -------------------------------------------------------------

library("dplyr")
library("forcats")
library("purrr")
library("readr")
library("stringr")

# Get paths -------------------------------------------------------------------

files <- list.files("Data", full.names = TRUE)
new_files <- str_subset(files, "202(1(0[2-9]|1[0-2])|20[1-5])")
old_files <- setdiff(files, new_files)

# Read data from before 2021-02 -----------------------------------------------

old_spec <- list(
  trip_duration = col_integer(),
  started_at = col_datetime(
    format = "%Y-%m-%d %H:%M:%S"
  ),
  ended_at = col_datetime(
    format = "%Y-%m-%d %H:%M:%S"
  ),
  start_station_id = col_integer(),
  start_station_name = col_character(),
  start_lat = col_double(),
  start_lng = col_double(),
  end_station_id = col_integer(),
  end_station_name = col_character(),
  end_lat = col_double(),
  end_lng = col_double(),
  bike_id = col_integer(),
  user_type = col_factor(
    levels = c("Customer", "Subscriber")
  ),
  birth_year =  col_integer(),
  gender = col_factor(
    levels = c("0", "1", "2")
  )
)

old_tripdata <- old_files %>%
  map_dfr(
    ~ read_csv(.,
        col_names = names(old_spec),
        col_types = old_spec,
        locale = locale(tz = "US/Eastern"),
        na = c("", "NA", "NULL"),
        progress = FALSE,
        skip = 1
    )
  )

# recode factors for consistency
old_tripdata <- old_tripdata %>%
  mutate(
    user_type = fct_recode(user_type,
      subscriber = "Subscriber",
      customer = "Customer"
    ),
    gender = fct_recode(gender,
      unknown = "0",
      male = "1",
      female = "2"
    )
  )

# Read data from after 2021-02 ------------------------------------------------

new_spec <- list(
  ride_id = col_character(),
  rideable_type = col_factor(
    levels = c("classic_bike", "docked_bike", "electric_bike")
  ),
  started_at = col_datetime(
    format = "%Y-%m-%d %H:%M:%S"
  ),
  ended_at = col_datetime(
    format = "%Y-%m-%d %H:%M:%S"
  ),
  start_station_name = col_character(),
  start_station_id = col_character(),
  end_station_name = col_character(),
  end_station_id = col_character(),
  start_lat = col_double(),
  start_lng = col_double(),
  end_lat = col_double(),
  end_lng = col_double(),
  member_casual = col_factor(
    levels = c("casual", "member")
  )
)

new_tripdata <- new_files %>%
  map_dfr(
    ~ read_csv(.,
        col_names = names(new_spec),
        col_types = new_spec,
        locale = locale(tz = "US/Eastern"),
        na = c("", "NA", "NULL"),
        progress = FALSE,
        skip = 1
    )
  )

# Pair frames for convenience -------------------------------------------------

paired_tripdata <- list(old_tripdata, new_tripdata)
