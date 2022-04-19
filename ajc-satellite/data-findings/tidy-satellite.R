library(tidyverse)

setwd("/mnt/c/Users/adavi/Documents/comp-journal/ajc-satellite/data-findings/")
data_files <- list.files("data_satellite", full.names = TRUE)

parse_hist_csv <- function(fname) {
    df <- read_csv(fname) %>%
        mutate(histogram = str_sub(histogram, 2, -2)) %>%
        separate_rows(histogram, sep = ", ") %>%
        separate(histogram, into = c("class", "value"), sep = "=") %>%
        mutate(year = str_split(fname, "_")[[1]][4])
    return(df)
}

df <- bind_rows(lapply(data_files, parse_hist_csv))
write_csv(df, "data-files/ncld_histogram_data.csv")