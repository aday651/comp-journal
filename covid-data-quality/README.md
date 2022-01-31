# Vaccination status of healthcare workers for COVID-19

Data sources:
- [COVID-19 Reported Patient Impact and Hospital Capacity by Facility](https://healthdata.gov/Hospital/COVID-19-Reported-Patient-Impact-and-Hospital-Capa/anag-cw7u)
- [COVID-19 Vaccinations in the United States by County](https://data.cdc.gov/Vaccinations/COVID-19-Vaccinations-in-the-United-States-County/8xkx-amqh)

Fields in the data sources relating to vaccination rates: 
- In the hospital survey data (note: collected on Wednesday's only):
    - `total_personnel_covid_vaccinated_doses_none_7_day` - The number reported 
        of healthcare personnel who have not yet received a single vaccine dose.
    - `total_personnel_covid_vaccinated_doses_one_7_day` - The current number 
        reported of healthcare personnel who have received at least one dose 
        of COVID-19 vaccination that is administered 
        in a multi-dose series. This field is meant to represent those who have
        begun but not completed the vaccination process. Does not include those 
        who received a single-dose vaccine in this field.
    - `total_personnel_covid_vaccinated_doses_all_7_day` - The current number 
        reported of healthcare personnel who have received a complete series 
        of a COVID-19 vaccination. Includes those who have received all doses 
        in a multi-dose series as well as those who received a single-dose vaccine.
- In the CDC county level data (selecting those as a 
fairest comparison to those above):
    - `Administered_Dose1_Recip_18PlusPop_Pct` - Percent of 18+ Pop 
    with at least one Dose by State of Residence
    - `Series_Complete_18PlusPop_Pct` - Percent of people 18+ who are 
    fully vaccinated (have second dose of a two-dose vaccine or one 
    dose of a single-dose vaccine) based on the jurisdiction and county
    where recipient lives. This percentage is capped at 99.99%.
    - Note that this always us to calculate the percentage of people
    in a county which are unvaccinated, have received exactly one-dose
    (excluding single-shot vaccines), and are fully vaccinated. Here,
    fully vaccinated does not require the individual to have had
    a booster shot.

Some data quality issues which are already reported or somewhat obvious:
- For the hospital survey data:
    - It is not needed by a hospital to report data on vaccination status (!!)
    - The definition of the `total_personnel_covid_vaccinated_doses_one_7_day`
    variable is inconsistent - it gives the number of "at least one dose"
    individuals, but is supposed to represent those who have begun but
    not finished vaccination (i.e, it should be exactly one dose). 
    - Suppressed values are put as -999999, which really messes with
    doing arithmetic calculations
- For the CDC county level data (source: [CDC page on county level data](https://www.cdc.gov/coronavirus/2019-ncov/vaccines/distributing/reporting-counties.html)):
    - California does not report county of residence for people
    who belong to a county of 20,000 people or fewer
    - Hawaii provides the CDC no county of residence data
    - Three counties in MA (Barnstable, Dukes, and Nantucket) do
    not have county level data reported due to small county sizes
    - There are no guarantees as of May 2021 as to whether
    data from New Hampshire is of use

Data quality issues to consider:
- Indicator for whether vaccination rates are reported
    - I mean, if it's not reported, it's not exactly good data, no?
- Non-positive number of workers
    - If a hospital has no workers, either something is up
    with the reporting, or there's something REALLY 
    interesting going on.
- Substantial changes in workers over time
    - Sometimes the number of individuals in a particular group
    within the same hospital changes substantially (e.g by
    multiple orders of magnitude) over a short time period.
- More fully vaccinated workers than "one shot or more" workers
    - This is probably due to ambiguity in how the variable
    is coded (the description is contradictory in its
    intent, and what is meant to be captured by it).
- Looking at standard deviations of not vaccinated percentages
in a hospital away from the population percentages in a county
    - If this is slightly negative, or **substantially** positive,
    then this could be evidence that there is something amiss here,
    as we would expect healthcare workers to be, if anything,
    more likely to be vaccinated than the population they are in.
    Significantly positive deviations would suggest a possible
    overestimation in counts, whereas slightly negative or
    significantly negative deviations could suggest underreporting.


Dates we'll look at:
- April 9th 2021 (the day used in the original map)
- November 5th 2021 (the day after the [Biden administration](https://www.whitehouse.gov/briefing-room/statements-releases/2021/11/04/fact-sheet-biden-administration-announces-details-of-two-major-vaccination-policies/) announced
a requirement for healthcare workers to be vaccinated)
- January 14th 2022 (the most recent response, and 10 days after
the original date given by the for Biden administration for when
healthcare workers would need to be vaccinated by)

