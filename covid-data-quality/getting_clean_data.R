library(tidyverse)
library(jsonlite)

survey_results <- read_csv('covid-data-quality/survey_results.csv')

survey_results_dq <- survey_results %>% select(-`...1`) %>%
    mutate(
        across(
            c(no_dose_personnel, one_dose_personnel, two_dose_personnel),
            ~ replace(., . == -999999, 0)
        ),
        data_reported = ifelse(
            no_dose_personnel + one_dose_personnel + two_dose_personnel > 0,
            1, 0), 
        correct_coding = ifelse(
            data_reported == 1 & one_dose_personnel >= two_dose_personnel,
            1, 0), 
        total_personnel = no_dose_personnel + pmax(one_dose_personnel, two_dose_personnel), 
        percentage_unvacc = no_dose_personnel / total_personnel,
        std_error = sqrt(percentage_unvacc*(1 - percentage_unvacc)/total_personnel)
    ) %>% group_by(hospital_pk) %>%
    mutate(
        personnel_iqr = quantile(total_personnel, 0.75, na.rm = TRUE) - quantile(total_personnel, 0.25, na.rm = TRUE), 
        personnel_lbd = quantile(total_personnel, 0.25, na.rm = TRUE) - 1.5*personnel_iqr, 
        personnel_ubd = quantile(total_personnel, 0.75, na.rm = TRUE) + 1.5*personnel_iqr
    ) %>% ungroup() %>% 
    mutate( 
        possible_incorrect_count = ifelse(
            total_personnel > personnel_ubd | total_personnel < personnel_lbd, 
            1, 0
        )
    )

covid_county <- read_csv('covid-data-quality/county_covid.csv') %>%
    select(-'...1') %>%
    mutate(percentage_unvacc_county = 1 - one_dose_pop/100)

covid_county

joined_data <- survey_results_dq %>%
    filter(collection_week %in% c(
            as.Date('2021-04-09'), 
            as.Date('2021-11-05'), 
            as.Date('2022-01-14')
    )) %>% left_join(covid_county, by = 
    c('collection_week' = 'date', 'fips_code' = 'fips')) %>%
    mutate(
        std_error_away_from_count_pop = (percentage_unvacc - percentage_unvacc_county)/std_error
    )

write_csv(joined_data, 'covid-data-quality/joined_data.csv')
