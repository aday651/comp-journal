library(tidyverse)
library(zoo)

df <- read_csv('ajc-satellite/data/lake-lanier-water.csv')[, 2:11]

dfl <- df %>% select(date, prop_water, prop_obs) %>% mutate(
    var_est = rollapplyr(
        prop_water, 6, var, na.rm = TRUE, fill = NA
    ))

dfl %>% ggplot(aes(x = date, y = var_est)) + geom_line()
