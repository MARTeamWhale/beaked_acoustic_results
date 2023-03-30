
# Helper script to run BWD_report_word.Rmd

library(here)
library(knitr)

################################################################################

# SET PARAMETERS


# required:

deployment = "MGL_2018_09" # name of deployment to summarize
metadata = "deployment_summary.csv" # name of metadata csv file
hourly = FALSE # true if validated on an hourly basis (otherwise assumes daily)
missing_data = TRUE # true if there is missing data within deployment period


# if missing_data = TRUE, specify dates below (if false, this will be ignored):

missing_data_start = as.Date("2019-05-06", format="%Y-%m-%d")
missing_data_end = as.Date("2019-05-11", format="%Y-%m-%d")

################################################################################

# don't need to modify anything below

#create output, input, and metadata folders if they do not already exist and check if Presence table and metadata are present.
while (!dir.exists(here("input"))) {dir.create(here("input"))}
if (dir.exists(here("input"))) {while(!file.exists(here("input",paste0(deployment,"_Beaked_Presence.xlsx")))) {stop("Missing Presence table! Please copy required XLSX file into input folder")}}
if (!dir.exists(here("output"))) {dir.create(here("output"))}
while (!dir.exists(here("metadata"))) {dir.create(here("metadata"))}
if (dir.exists(here("metadata"))) {while (!file.exists(here("metadata/deployment_summary.csv"))) {stop("Missing Metadata! Please copy updated deployment_summary CSV generated from the Whale Equipment Metadatabase into the metadata folder")}}

# define function
render_BWD_report = function(
  deployment, metadata, hourly, missing_data, missing_data_start, missing_data_end) {

  rmarkdown::render(
    "BWD_report_word.Rmd",
      params = list(
        deployment = deployment,
        metadata = metadata,
        hourly = hourly,
        missing_data = missing_data,
        missing_data_start = missing_data_start,
        missing_data_end = missing_data_end
      ),
    output_file = here("output", paste0("BWD_Report-", deployment, ".docx"))
  )
}

# render report based on parameters set above
render_BWD_report(deployment, metadata, hourly, missing_data, missing_data_start, missing_data_end)
