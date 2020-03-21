# Load necessary packages -------------------------------------------------
# install.packages("tidyverse")
library(tidyverse)
# install.packages("rvest")
library(rvest)


# Scrape Pennsylvania case data from Google ------------------------------
pa_dept_health_covid19_url <- "https://www.health.pa.gov/topics/disease/coronavirus/Pages/Cases.aspx"
pa_dept_health_covid19_html <- read_html(pa_dept_health_covid19_url)
pa_dept_health_covid19_html_node <- html_node(pa_dept_health_covid19_html,
                                      xpath = '//*[@id="ctl00_PlaceHolderMain_PageContent__ControlWrapper_RichHtmlField"]/div[2]/table')
df_covid19_cases_pa <- html_table(pa_dept_health_covid19_html_node,
                                  fill = TRUE)
head(df_covid19_cases_pa)


# Clean dataframe ---------------------------------------------------------
# Rename columns
names(df_covid19_cases_pa) <- c("County", "Cases", "Deaths")

# Remove hidden character from county names
df_covid19_cases_pa$Location <- gsub("\u200B", "", df_covid19_cases_pa$County)

# Make confimred cases column numeric
df_covid19_cases_pa$cumulative_confirmed_cases <- gsub("\u200B", "", df_covid19_cases_pa$Cases)
df_covid19_cases_pa$cumulative_confirmed_cases <- as.numeric(df_covid19_cases_pa$cumulative_confirmed_cases)

# Make deaths column numeric
df_covid19_cases_pa$deaths <- gsub("\u200B", "", df_covid19_cases_pa$Deaths)
df_covid19_cases_pa$deaths <- as.numeric(df_covid19_cases_pa$deaths)

# Remove old/unused columns
df_covid19_cases_pa$County <- NULL
df_covid19_cases_pa$Cases <- NULL
df_covid19_cases_pa$Deaths <- NULL

# Add blank recovered column until PA releases those figures
df_covid19_cases_pa$recovered <- NA

# TO-DO: Get estimate population of county and calculate cases per 1m citizens to match worldwide dataframe

# Add updated date column
df_covid19_cases_pa$updated_date <- Sys.time()