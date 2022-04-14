library(tidyverse)
library(viridis)
library(cowplot)
setwd("/mnt/c/Users/adavi/Documents/comp-journal/ajc-satellite/data-findings/")

# y1_statefips: origin from year 1
# y2_statefips: destination from year 2:
# 01-56: states, 57: foreign
# n1: number of returns (roughly = number of households)
# n2: number of personal exemptions (roughly = number of individuals, although
#  I have no idea if this includes kids + if the ACS data does)
# agi: adjusted gross income (in thousands of dollars)

# In all seriousness, what am I actually trying to achieve here?
# - Want to try and find where people of low income are moving.
# - Information available from here is:
#   - Number of people who did not migrate counties
#   - Number of households and people who moved from county i to county j
#   - Average household income of those who did
# - Can this information be useful for this? Note that if we had information
# beyond that of simply the average income (i.e the bands), then we would
# be good.
# - What data can I get from the ACS?
#   - For each census tract, information on the income of individuals
#     who moved there 

# Here we examine migration data from [the IRS](https://www.irs.gov/statistics/soi-tax-stats-migration-data), which details migration patterns inferred
# from matching of tax returns, and gives some information also on the
# income of people who move.

# ```{r}
# migration_16 <- read_csv('../data/migration/countyoutflow1617.csv')
# migration_17 <- read_csv('../data/migration/countyoutflow1718.csv')
# migration_18 <- read_csv('../data/migration/countyoutflow1819.csv')
# ```

outflow_18 <- read_csv("../data/migration/countyoutflow1819.csv")
outflow_17 <- read_csv("../data/migration/countyoutflow1718.csv")
outflow_16 <- read_csv("../data/migration/countyoutflow1617.csv")

# Looking at the overall income bands in Georgia
agi_stub_to_bands <- tibble(
    agi_stub = c(0, 1, 2, 3, 4, 5, 6, 7),
    income_band = c("All", "$1 under $10,000",
        "$10,000 under $25,000",
        "$25,000 under $50,000",
        "$50,000 under $75,000",
        "$75,000 under $100,000",
        "$100,000 under $200,000",
        "$200,000 or more"
    )
)

summary_18 %>% 
    filter(state == "GA") %>%
    left_join(agi_stub_to_bands) %>%
    select(
        income_band, total_n1_0, total_y1_agi_0, total_y2_agi_0,
        inflow_n1_0, outflow_n1_0
    )

county_geoid <- outflow_18 %>%
    select(y2_statefips, y2_countyfips, y2_countyname) %>%
    filter(
        y2_statefips == 13,
        str_detect(y2_countyname, "Non-migrant", negate = TRUE)
    ) %>%
    unite(GEOID, c("y2_statefips", "y2_countyfips"), sep = "") %>%
    unique() %>%
    rename(county_name = y2_countyname)

atlanta_msa_1 <- c(
    'Fulton', 'Gwinnett',
    'Cobb', 'DeKalb', 'Clayton',
    'Cherokee', 'Forsyth',
    'Henry', 'Paulding', 'Coweta',
    'Douglas', 'Fayette', 'Carroll',
    'Newton', 'Bartow', 'Walton', 
    'Rockdale'
)

atlanta_counties <- paste(atlanta_msa_1, "County")

outflow_df <- outflow_18 %>% 
    filter(
        y1_statefips == 13,
        str_detect(y2_countyname, "Non-migrant", negate = TRUE)
    ) %>%
    unite(y1_GEOID, c("y1_statefips", "y1_countyfips"), sep = "") %>%
    left_join(county_geoid, by = c("y1_GEOID" = "GEOID"))
    
    
    
    unite(y2_GEOID, c("y2_statefips", "y2_countyfips"), sep = "") %>%
    select(y1_GEOID, y2_GEOID, n1, agi) %>%



    rename(y1_county = county_name) %>%
    left_join(county_geoid, by = c("y2_GEOID" = "GEOID")) %>%
    rename(y2_county = county_name) %>%
    filter(
        y1_county %in% atlanta_counties, y2_county %in% atlanta_counties
    ) %>% 
    select(y1_county, y2_county, n1, agi)



outflow_matrix <- outflow_df %>%
    select(y1_county, y2_county, n1) %>%
    reshape2::acast(y1_county ~ y2_county) %>%
    as.matrix()

# Note the following: n1 equals the number of people who moved into
# y2_county from y1_county, and the i-th row and j-th column of
# outflow_matrix corresponds to the i-th y1_county and the j-th
# y2_county. In particular, outflow_matrix - t(outflow_matrix)

# a_{ij} = number who moved from county i to county j
# a_{ij} - a_{ji} = net migration from county i to j, so if this number
# is positive, more people moved from county i to county j than vice-versa

outflow_df %>%
    ggplot(aes(x = y1_county, y = y2_county, fill = n1)) + 
    geom_tile() +
    scale_fill_viridis() +
    labs(
        x = "County Moved Out From",
        y = "County Moved Into",
        fill = "Number of Households"
    ) +
    coord_equal() +
    theme(
        axis.text.x = element_text(angle = 270),
        legend.position = "bottom",
        legend.key.width = unit(1.4, "cm")
    )

p1 <- (outflow_matrix - t(outflow_matrix)) %>%
    reshape2::melt() %>%
    ggplot(aes(x = Var1, y = Var2, fill = value)) +
    geom_tile() +
    scale_fill_viridis() +
    labs(
        x = "Origin County",
        y = "Destination County",
        fill = "Net Household Migration",
        title = "Net Household Migration Between Counties"
    ) + coord_equal() +
    theme(
        axis.text.x = element_text(angle = 270),
        legend.position = "bottom",
        legend.key.width = unit(1.4, "cm")
    )


## Looking at outflow income

outflow_income_matrix <- outflow_df %>%
    mutate(avg_income = agi / n1) %>%
    select(y1_county, y2_county, avg_income) %>%
    reshape2::acast(y1_county ~ y2_county) %>%
    as.matrix()

p2 <- outflow_df %>%
    mutate(avg_income = agi / n1) %>%
    complete(y1_county, y2_county) %>%
    ggplot(aes(x = y1_county, y = y2_county, fill = 1000 * avg_income)) + 
    geom_tile() +
    scale_fill_viridis(direction = -1) +
    labs(
        x = "County Moved Out From",
        y = "County Moved Into",
        fill = "Average Household Income",
        title = "Average Household Income of Migrating Households"
    ) +
    coord_equal() +
    theme(
        axis.text.x = element_text(angle = 270),
        legend.position = "bottom",
        legend.key.width = unit(1.4, "cm")
    )

(outflow_income_matrix - t(outflow_income_matrix)) %>%
    reshape2::melt() %>%
    ggplot(aes(x = Var1, y = Var2, fill = 1000 * value)) +
    geom_tile() +
    scale_fill_viridis(direction = -1) +
    labs(
        x = "Origin County",
        y = "Destination County",
        fill = "Household Income Distance",
        title = "Net Difference in Average Household Income of Migrating Households"
    ) + coord_equal() +
    theme(
        axis.text.x = element_text(angle = 270),
        legend.position = "bottom",
        legend.key.width = unit(1.4, "cm")
    )

plot_grid(p1, p2)
