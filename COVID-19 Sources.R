

# Create list of dataframes -----------------------------------------------
list_of_dataframes <- c(
  "Global COVID-19 Cases",
  "Pennsylvania COVID-19 Cases by County",
  "Pennsylvania Population by Age Group",
  "Ohio COVID-19 Cases by County",
  "Ohio Population by Age Group",
  "West Virginia COVID-19 Cases by County",
  "West Virginia Population by Age Group",
  "New York COVID-19 Cases by County",
  "New York Population by Age Group",
)


# Create list of source names --------------------------------------------------
list_of_sources <- c(
  "Google's Coronavirus Dashboard",
  "Pennsylvania Department of Health",
  "U.S. Census 2018 ACS",
  "Ohio Department of Health",
  "U.S. Census 2018 ACS",
  "West Virginia Department of Health and Human Resources",
  "U.S. Census 2018 ACS",
  "New York Department of Health",
  "U.S. Census 2018 ACS"
)


# Create list of source links ---------------------------------------------
list_of_links <- c(
  google_covid19_url,
  pa_dept_health_covid19_url,
  "Retrieved via tidycensus package",
  oh_dept_health_covid19_url,
  "Retrieved via tidycensus package",
  wv_dept_health_covid19_url,
  "Retrieved via tidycensus package",
  ny_dept_health_covid19_url,
  "Retrieved via tidycensus package"
)


# Create list of R scripts ---------------------------------------------
list_of_r_scripts <- c(
  "C:/Users/oneno/OneDrive/UPMC/Scripts/COVID-19 Case Data Pull - Global.R",
  "C:/Users/oneno/OneDrive/UPMC/Scripts/COVID-19 Case Data Pull - Pennsylvania.R",
  "C:/Users/oneno/OneDrive/UPMC/Scripts/COVID-19 Case Data Pull - Pennsylvania.R",
  "C:/Users/oneno/OneDrive/UPMC/Scripts/COVID-19 Case Data Pull - Ohio.R",
  "C:/Users/oneno/OneDrive/UPMC/Scripts/COVID-19 Case Data Pull - Ohio.R",
  "C:/Users/oneno/OneDrive/UPMC/Scripts/COVID-19 Case Data Pull - West Virginia.R",
  "C:/Users/oneno/OneDrive/UPMC/Scripts/COVID-19 Case Data Pull - West Virginia.R",
  "C:/Users/oneno/OneDrive/UPMC/Scripts/COVID-19 Case Data Pull - New York.R",
  "C:/Users/oneno/OneDrive/UPMC/Scripts/COVID-19 Case Data Pull - New York.R"
)


# Create dataframe of sources ---------------------------------------------
df_sources <- as.data.frame(
  list(
    list_of_dataframes,
    list_of_sources,
    list_of_links,
    list_of_r_scripts
  ))
names(df_sources) <- c(
  "Data",
  "Source",
  "Link to source",
  "R Script location"
)
