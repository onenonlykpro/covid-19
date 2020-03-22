
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
df_md_county_population <- get_acs(geography ="county",
                                   variables = list_of_acs_variables,
                                   year = 2018,
                                   output = "tidy",
                                   state = "MD",
                                   moe_level = 90,
                                   survey = "acs1",
                                   show_call = FALSE)

# Preserve GEOIDs and full county names
df_md_county_GEOIDs <- unique(df_md_county_population[c("GEOID", "NAME")])
df_md_county_GEOIDs$Location <- gsub(" County, Maryland", "", df_md_county_GEOIDs$NAME)

# Ensure that each population group gets it own column and get total population
df_md_county_population$moe <- NULL
df_md_county_population <- cast(df_md_county_population,
                                NAME ~ variable,
                                value = "estimate")
names(df_md_county_population) <- c("NAME",
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
df_md_county_population$estimated_population <- 
     df_md_county_population$age_4_or_under +
     df_md_county_population$age_5_to_9 +
     df_md_county_population$age_10_to_14 + 
     df_md_county_population$age_15_to_19 + 
     df_md_county_population$age_20_to_24 + 
     df_md_county_population$age_25_to_29 + 
     df_md_county_population$age_30_to_34 + 
     df_md_county_population$age_35_to_39 + 
     df_md_county_population$age_40_to_44 +
     df_md_county_population$age_45_to_49 +
     df_md_county_population$age_50_to_54 + 
     df_md_county_population$age_55_to_59 + 
     df_md_county_population$age_60_to_64 +
     df_md_county_population$age_65_to_69 +
     df_md_county_population$age_70_to_74 + 
     df_md_county_population$age_75_to_79 +
     df_md_county_population$age_80_to_84 +
     df_md_county_population$age_85_or_older

# Scrape Maryland case data from MD Dept. of Health ------------------------------
md_dept_health_covid19_url <- "https://coronavirus.maryland.gov/"
md_dept_health_covid19_html <- read_html(md_dept_health_covid19_url)
html_text(md_dept_health_covid19_html,
          xpath = '//*[@id="ember30"]/div[2]')
?html_node
md_dept_health_covid19_html_node <- html_node(md_dept_health_covid19_html,
                                              xpath = '//*[@id="ember74"]/div/p[2]/strong')

#df_covid19_cases_md <- html_text(md_dept_health_covid19_html_node)
#df_covid19_cases_md
