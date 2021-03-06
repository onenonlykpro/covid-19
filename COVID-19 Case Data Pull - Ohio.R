
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
df_oh_county_population <- get_acs(geography ="county",
                                   variables = list_of_acs_variables,
                                   year = 2018,
                                   output = "tidy",
                                   state = "OH",
                                   moe_level = 90,
                                   survey = "acs1",
                                   show_call = FALSE)

# Preserve GEOIDs and full county names
df_oh_county_GEOIDs <- unique(df_oh_county_population[c("GEOID", "NAME")])
df_oh_county_GEOIDs$Location <- gsub(" County, Ohio", "", df_oh_county_GEOIDs$NAME)

# Ensure that each population group gets it own column and get total population
df_oh_county_population$moe <- NULL
df_oh_county_population <- cast(df_oh_county_population,
                                NAME ~ variable,
                                value = "estimate")
names(df_oh_county_population) <- c("NAME",
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
df_oh_county_population$estimated_population <- 
     df_oh_county_population$age_4_or_under +
     df_oh_county_population$age_5_to_9 +
     df_oh_county_population$age_10_to_14 + 
     df_oh_county_population$age_15_to_19 + 
     df_oh_county_population$age_20_to_24 + 
     df_oh_county_population$age_25_to_29 + 
     df_oh_county_population$age_30_to_34 + 
     df_oh_county_population$age_35_to_39 + 
     df_oh_county_population$age_40_to_44 +
     df_oh_county_population$age_45_to_49 +
     df_oh_county_population$age_50_to_54 + 
     df_oh_county_population$age_55_to_59 + 
     df_oh_county_population$age_60_to_64 +
     df_oh_county_population$age_65_to_69 +
     df_oh_county_population$age_70_to_74 + 
     df_oh_county_population$age_75_to_79 +
     df_oh_county_population$age_80_to_84 +
     df_oh_county_population$age_85_or_older


# Scrape Ohio case data from OH Dept. of Health ------------------------------
oh_dept_health_covid19_url <- "https://coronavirus.ohio.gov/wps/portal/gov/covid-19/"
oh_dept_health_covid19_html <- read_html(oh_dept_health_covid19_url)
oh_dept_health_covid19_html_node <- html_node(oh_dept_health_covid19_html,
                                              xpath = '//*[@id="odx-main-content"]/article/section[2]/div/div[3]/div/div/div/div[1]/div')

# OH Dept of Health lists county cases counts in text. Import then structure to dataframe
# Remove extra text and characters
df_covid19_cases_oh <- html_text(oh_dept_health_covid19_html_node)
df_covid19_cases_oh <- gsub("[\r\n]", "", df_covid19_cases_oh)
df_covid19_cases_oh <- gsub(" Number of counties with cases: ", "", df_covid19_cases_oh)
df_covid19_cases_oh <- gsub("^                            ", "", df_covid19_cases_oh)
df_covid19_cases_oh <- gsub("[*]", "", df_covid19_cases_oh)
# Separate each county item into element in a list
df_covid19_cases_oh <- strsplit(df_covid19_cases_oh, ", ")
# Separate county and counts into two elements, but maintain their order to make merging into dataframe easier
list_of_counties <- c()
list_of_case_counts <- c()
for (item in df_covid19_cases_oh[[1]]) {
     # Remove parenthesis
     item <- gsub("[(]", "", item)
     item <- gsub("[)]", "", item)
     # Separate county name and count on ' '
     county_and_count <- strsplit(item, " ")
     county_name <- county_and_count[[1]][1]
     county_count <- county_and_count[[1]][2]
     # Append county and count to lists
     list_of_counties <- append(list_of_counties, county_name)
     list_of_case_counts <- append(list_of_case_counts, county_count)
}
# Combine lists to dataframe
df_covid19_cases_oh <- as.data.frame(
     list(
          list_of_counties,
          list_of_case_counts
     ))
names(df_covid19_cases_oh) <- c(
     "Location",
     "cumulative_confirmed_cases"
)


# Clean dataframe ---------------------------------------------------------
# Add State and Country column
df_covid19_cases_oh$state_or_province <- "Ohio"
df_covid19_cases_oh$country <- "United States"

# Join population estimate and GEOIDs to COVID-19 dataset
df_oh_county_GEOIDs <- merge(df_oh_county_GEOIDs, df_oh_county_population[,c("NAME", "estimated_population")],
                             all.x = TRUE)
df_covid19_cases_oh <- merge(df_covid19_cases_oh, df_oh_county_GEOIDs[,c("Location", "GEOID", "estimated_population")],
                             all.x = TRUE)

# Make confirmed cases column numeric
df_covid19_cases_oh$cumulative_confirmed_cases <- as.numeric(df_covid19_cases_oh$cumulative_confirmed_cases)

# Make deaths column numeric (TO-DO: Monitor OH Dept. of Health for more specific mortality counts by counts - not specific as of 3/22/2020)
df_covid19_cases_oh$deaths <- NA
df_covid19_cases_oh$deaths <- as.numeric(df_covid19_cases_oh$deaths)

# Add blank recovered column until OH releases those figures
df_covid19_cases_oh$recovered <- NA


# Match dataframe to worldwide dataset ------------------------------------
# Add share of infected population
df_covid19_cases_oh$share_of_infected_population <- df_covid19_cases_oh$cumulative_confirmed_cases / df_covid19_cases_oh$estimated_population

# Add cases per 1m citizens
df_covid19_cases_oh$cases_per_1m_citizens <- df_covid19_cases_oh$share_of_infected_population * 1000000

# Add mortality rate
df_covid19_cases_oh$mortality_rate <- df_covid19_cases_oh$deaths / df_covid19_cases_oh$cumulative_confirmed_cases

# Add recovery rate
df_covid19_cases_oh$recovery_rate <- df_covid19_cases_oh$recovered / df_covid19_cases_oh$cumulative_confirmed_cases

# Add ongoing or unresolved cases
df_covid19_cases_oh$ongoing_or_unresolved_confirmed_cases <- df_covid19_cases_oh$cumulative_confirmed_cases - df_covid19_cases_oh$deaths - df_covid19_cases_oh$recovered

# Add updated date column
df_covid19_cases_oh$updated_date <- Sys.time()


# Clean workspace to save memory ------------------------------------------
rm(oh_dept_health_covid19_html)
rm(oh_dept_health_covid19_html_node)
rm(county_count)
rm(county_name)
rm(county_and_count)
rm(item)
rm(list_of_case_counts)
rm(list_of_counties)