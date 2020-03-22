
# Load necessary packages -------------------------------------------------
# install.packages("tidyverse")
library(tidyverse)
library(dplyr)
# install.packages("rvest")
library(rvest)
# install.packages("tidycensus")
library(tidycensus)
# install.packages("reshape")
library(reshape)


# Get population estimates of counties ------------------------------------
# census_api_key("YOUR KEY GOES HERE", install = TRUE)
list_of_acs_variables <- c("S0101_C01_002E", # Estimate - Under 5 years
                           "S0101_C01_003E", # Estimate - 5 to 9 years
                           "S0101_C01_004E", # Estimate - 10 to 14 years
                           "S0101_C01_005E", # Estimate - 15 to 19 years
                           "S0101_C01_006E", # Estimate - 20 to 24 years
                           "S0101_C01_007E", # Estimate - 25 to 29 years
                           "S0101_C01_008E", # Estimate - 30 to 34 years
                           "S0101_C01_009E", # Estimate - 35 to 39 years
                           "S0101_C01_010E", # Estimate - 40 to 44 years
                           "S0101_C01_011E", # Estimate - 45 to 49 years
                           "S0101_C01_012E", # Estimate - 50 to 54 years
                           "S0101_C01_013E", # Estimate - 55 to 59 years
                           "S0101_C01_014E", # Estimate - 60 to 64 years
                           "S0101_C01_015E", # Estimate - 65 to 69 years
                           "S0101_C01_016E", # Estimate - 70 to 74 years
                           "S0101_C01_017E", # Estimate - 75 to 79 years
                           "S0101_C01_018E", # Estimate - 80 to 84 years
                           "S0101_C01_019E") # Estimate - 85 years and over
df_ny_county_population <- get_acs(geography ="county",
                                   variables = list_of_acs_variables,
                                   year = 2018,
                                   output = "tidy",
                                   state = "NY",
                                   moe_level = 90,
                                   survey = "acs1",
                                   show_call = FALSE)

# Preserve GEOIDs and full county names
df_ny_county_GEOIDs <- unique(df_ny_county_population[c("GEOID", "NAME")])
df_ny_county_GEOIDs$Location <- gsub(" County, New York", "", df_ny_county_GEOIDs$NAME)

# Ensure that each population group gets it own column and get total population
df_ny_county_population$moe <- NULL
df_ny_county_population <- cast(df_ny_county_population,
                                NAME ~ variable,
                                value = "estimate")
names(df_ny_county_population) <- c("NAME",
                                    "age_4_or_under",
                                    "age_5_to_9",
                                    "age_10_to_14",
                                    "age_15_to_19",
                                    "age_20_to_24",
                                    "age_25_to_29",
                                    "age_30_to_34",
                                    "age_35_to_39",
                                    "age_40_to_44",
                                    "age_45_to_49",
                                    "age_50_to_54",
                                    "age_55_to_59",
                                    "age_60_to_64",
                                    "age_65_to_69",
                                    "age_70_to_74",
                                    "age_75_to_79",
                                    "age_80_to_84",
                                    "age_85_or_older")

# Calculate total population
df_ny_county_population$estimated_population <- 
     df_ny_county_population$age_4_or_under +
     df_ny_county_population$age_5_to_9 +
     df_ny_county_population$age_10_to_14 + 
     df_ny_county_population$age_15_to_19 + 
     df_ny_county_population$age_20_to_24 + 
     df_ny_county_population$age_25_to_29 + 
     df_ny_county_population$age_30_to_34 + 
     df_ny_county_population$age_35_to_39 + 
     df_ny_county_population$age_40_to_44 +
     df_ny_county_population$age_45_to_49 +
     df_ny_county_population$age_50_to_54 + 
     df_ny_county_population$age_55_to_59 + 
     df_ny_county_population$age_60_to_64 +
     df_ny_county_population$age_65_to_69 +
     df_ny_county_population$age_70_to_74 + 
     df_ny_county_population$age_75_to_79 +
     df_ny_county_population$age_80_to_84 +
     df_ny_county_population$age_85_or_older

# Scrape Pennsylvania case data from PA Dept. of Health ------------------------------
ny_dept_health_covid19_url <- "https://coronavirus.health.ny.gov/county-county-breakdown-positive-cases"
ny_dept_health_covid19_html <- read_html(ny_dept_health_covid19_url)
ny_dept_health_covid19_html_node <- html_node(ny_dept_health_covid19_html,
                                              xpath = '/html/body/div[3]/div/main/div/div/div[2]/div/div/div/div/div[2]/table')
df_covid19_cases_ny <- html_table(ny_dept_health_covid19_html_node,
                                  fill = TRUE)


# Clean dataframe ---------------------------------------------------------
# Rename columns
names(df_covid19_cases_ny) <- c("Location", "cumulative_confirmed_cases")

# Remove Total row
df_covid19_cases_ny <- df_covid19_cases_ny[!(df_covid19_cases_ny$Location == "Total Number of Positive Cases"),]

# Change New Yourk city to New YorK
df_covid19_cases_ny$Location[df_covid19_cases_ny$Location == "New York City"] <- "New York"

# Add State and Country column
df_covid19_cases_ny$state_or_province <- "New York"
df_covid19_cases_ny$country <- "United States"

# Join population estimate and GEOIDs to COVID-19 dataset
df_ny_county_GEOIDs <- merge(df_ny_county_GEOIDs, df_ny_county_population[,c("NAME","estimated_population")], all.x = TRUE)
df_covid19_cases_ny <- merge(df_covid19_cases_ny, df_ny_county_GEOIDs[,c("Location","GEOID", "estimated_population")], all.x = TRUE)

# Make confimred cases column numeric
df_covid19_cases_ny$cumulative_confirmed_cases <- as.numeric(df_covid19_cases_ny$cumulative_confirmed_cases)

# Add blank deaths column until NY releases those figures
df_covid19_cases_ny$deaths <- NA
df_covid19_cases_ny$deaths <- as.numeric(df_covid19_cases_ny$deaths)

# Add blank recovered column until NY releases those figures
df_covid19_cases_ny$recovered <- NA
df_covid19_cases_ny$recovered <- as.numeric(df_covid19_cases_ny$recovered)


# Match dataframe to worldwide dataset ------------------------------------
# Add share of infected population
df_covid19_cases_ny$share_of_infected_population <- df_covid19_cases_ny$cumulative_confirmed_cases / df_covid19_cases_ny$estimated_population

# Add cases per 1m citizens
df_covid19_cases_ny$cases_per_1m_citizens <- df_covid19_cases_ny$share_of_infected_population * 1000000

# Add mortality rate
df_covid19_cases_ny$mortality_rate <- df_covid19_cases_ny$deaths / df_covid19_cases_ny$cumulative_confirmed_cases

# Add recovery rate
df_covid19_cases_ny$recovery_rate <- df_covid19_cases_ny$recovered / df_covid19_cases_ny$cumulative_confirmed_cases

# Add ongoing or unresolved cases
df_covid19_cases_ny$ongoing_or_unresolved_confirmed_cases <- df_covid19_cases_ny$cumulative_confirmed_cases - df_covid19_cases_ny$deaths - df_covid19_cases_ny$recovered

# Add updated date column
df_covid19_cases_ny$updated_date <- Sys.time()


# Clean workspace to save memory ------------------------------------------
rm(ny_dept_health_covid19_html)
rm(ny_dept_health_covid19_html_node)
