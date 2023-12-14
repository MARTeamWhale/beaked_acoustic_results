
# Helper script to run BWD_report_word.Rmd

library(here)
library(knitr)

################################################################################

# SET PARAMETERS


# required:

project = "DFO_MAR"
deployment = "GBK_2020_09" # name of deployment to summarize
metadata = "deployment_summary.csv" # name of metadata csv file
hourly = FALSE # true if validated on an hourly basis (otherwise assumes daily)
missing_data = TRUE # true if there is missing data within deployment period


# if missing_data = TRUE, specify start and end date(s) of missing data period(s) (if false, this will be ignored)

# NOTES:
  # 1) use format c("YYYY-MM-DD", "YYYY-MM-DD")
  # 2) if missing data spans two years, list as two separate periods (ending Dec 31 and starting Jan 1)

missing_data_starts = c("2020-11-16","2021-03-09","2021-05-05")
missing_data_ends = c("2020-12-24","2021-03-28","2021-05-24")

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
        missing_data_starts = missing_data_starts,
        missing_data_ends = missing_data_ends
      ),
    output_file = paste0(r"(R:\\Science\\CetaceanOPPNoise\\CetaceanOPPNoise_4\\PAM_analysis)",
                         "\\", project, "\\", deployment, "\\", "BWD_Report-", deployment, ".docx")
  )
}

# render report based on parameters set above
render_BWD_report(project, deployment, metadata, hourly, missing_data, missing_data_start, missing_data_end)
