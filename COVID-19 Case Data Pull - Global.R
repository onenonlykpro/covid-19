# Load necessary packages -------------------------------------------------
# install.packages("tidyverse")
library(tidyverse)
# install.packages("rvest")
library(rvest)


# Scrape international case data from Google ------------------------------
google_covid19_url <- "https://google.org/crisisresponse/covid19-map"
google_covid19_html <- read_html(google_covid19_url)
google_covid19_html_node <- html_node(google_covid19_html,
                                      xpath = '//*[@id="main"]/div[2]/div/div/div/div/div[1]/table')
df_covid19_cases_global <- html_table(google_covid19_html_node,
                                      fill = TRUE)


# Clean dataframe ---------------------------------------------------------
# Remove row containing international counts
df_covid19_cases_global <- df_covid19_cases_global[!(df_covid19_cases_global$Location=="Worldwide"),]

# Make confimred cases column numeric
df_covid19_cases_global$cumulative_confirmed_cases <- gsub(",", "", df_covid19_cases_global$`Confirmed cases`)
df_covid19_cases_global$cumulative_confirmed_cases <- as.numeric(df_covid19_cases_global$cumulative_confirmed_cases)

# Make cases per one million people column numeric
df_covid19_cases_global$cases_per_1m_citizens <- gsub(",", "", df_covid19_cases_global$`Cases per 1M people`)
df_covid19_cases_global$cases_per_1m_citizens <- as.numeric(df_covid19_cases_global$cases_per_1m_citizens)

# Make recovered column numeric
df_covid19_cases_global$recovered <- gsub(",", "", df_covid19_cases_global$Recovered)
df_covid19_cases_global$recovered <- as.numeric(df_covid19_cases_global$recovered)

# Make deaths column numeric
df_covid19_cases_global$deaths <- gsub(",", "", df_covid19_cases_global$Deaths)
df_covid19_cases_global$deaths <- as.numeric(df_covid19_cases_global$deaths)

# Remove old/unused columns
df_covid19_cases_global$`Confirmed cases` <- NULL
df_covid19_cases_global$`Cases per 1M people` <- NULL
df_covid19_cases_global$Recovered <- NULL
df_covid19_cases_global$Deaths <- NULL

# Get estimated share of population that is either currently or has been infected with COVID-19
df_covid19_cases_global$share_of_infected_population <- df_covid19_cases_global$cases_per_1m_citizens / 1000000

# Get population estimate from cases per 1M
df_covid19_cases_global$estimated_population <- df_covid19_cases_global$cumulative_confirmed_cases / df_covid19_cases_global$share_of_infected_population

# Get mortality rate of COVID-19 in each country
df_covid19_cases_global$mortality_rate <- df_covid19_cases_global$deaths / df_covid19_cases_global$cumulative_confirmed_cases

# Get recovery rate of COVID-19 in each country
df_covid19_cases_global$recovery_rate <- df_covid19_cases_global$recovered / df_covid19_cases_global$cumulative_confirmed_cases

# Get estimate number of current COVID-19 ongoing
df_covid19_cases_global$ongoing_or_unresolved_confirmed_cases <- df_covid19_cases_global$cumulative_confirmed_cases - df_covid19_cases_global$recovered - df_covid19_cases_global$deaths 

# Add updated date column
df_covid19_cases_global$updated_date <- Sys.time()


# Clean workspace to save memory ------------------------------------------
rm(google_covid19_html)
rm(google_covid19_html_node)
