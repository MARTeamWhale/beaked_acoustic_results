
# Helper script to run BWD_report_word.Rmd

library(here)
library(knitr)

################################################################################

# SET PARAMETERS


# required:

project = "DFO_MAR"
deployment = "FCH_2020_09" # name of deployment to summarize
metadata = "deployment_summary.csv" # name of metadata csv file
hourly = FALSE # true if validated on an hourly basis (otherwise assumes daily)
missing_data = FALSE # true if there is missing data within deployment period


# if missing_data = TRUE, specify dates below (if false, this will be ignored):

missing_data_start = as.Date("2019-05-06", format="%Y-%m-%d")
missing_data_end = as.Date("2019-05-11", format="%Y-%m-%d")

################################################################################

# don't need to modify anything below

# define function
render_BWD_report = function(
  project, deployment, metadata, hourly, missing_data, missing_data_start, missing_data_end) {

  rmarkdown::render(
    "BWD_report_word.Rmd",
      params = list(
        project = project,
        deployment = deployment,
        metadata = metadata,
        hourly = hourly,
        missing_data = missing_data,
        missing_data_start = missing_data_start,
        missing_data_end = missing_data_end
      ),
    output_file = paste0(r"(R:\\Science\\CetaceanOPPNoise\\CetaceanOPPNoise_4\\PAM_analysis)",
                         "\\", project, "\\", deployment, "\\", "BWD_Report-", deployment, ".docx")
  )
}

# render report based on parameters set above
render_BWD_report(project, deployment, metadata, hourly, missing_data, missing_data_start, missing_data_end)
