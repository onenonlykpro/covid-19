

# Create list of dataframes -----------------------------------------------
list_of_dataframes <- c(
  "Global COVID-19 Cases",
  "Pennsylvania COVID-19 Cases"
)


# Create list of source names --------------------------------------------------
list_of_sources <- c(
  "Google's Coronavirus Dashboard",
  "Pennsylvania Department of Health"
)


# Create list of source links ---------------------------------------------
list_of_links <- c(
  google_covid19_url,
  pa_dept_health_covid19_url
)


# Create list of R scripts ---------------------------------------------
list_of_r_scripts <- c(
  "C:/Users/oneno/OneDrive/UPMC/Scripts/COVID-19 Case Data Pull - Global.R",
  "C:/Users/oneno/OneDrive/UPMC/Scripts/COVID-19 Case Data Pull - Pennsylvania.R"
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
