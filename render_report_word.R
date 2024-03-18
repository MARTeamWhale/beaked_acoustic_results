
# Helper script to run BWD_report_word.Rmd

library(pacman)
pacman::p_load(here, knitr)

################################################################################

# SET PARAMETERS


# required:

project = "DFO_MAR"
deployment = "EFC_2021_08" # name of deployment to summarize
metadata = "deployment_summary.csv" # name of metadata csv file
hourly = FALSE # true if validated on an hourly basis (otherwise assumes daily)
missing_data = FALSE # true if there is missing data within deployment period


# if missing_data = TRUE, specify start and end date(s) of missing data period(s) (if false, this will be ignored)

# NOTES:
  # 1) use format c("YYYY-MM-DD", "YYYY-MM-DD")
  # 2) if missing data spans two years, list as two separate periods (ending Dec 31 and starting Jan 1)

missing_data_starts = c(" ")
missing_data_ends = c(" ")

################################################################################

# don't need to modify anything below

# define function
render_BWD_report = function(
  project, deployment, metadata, hourly, missing_data, missing_data_starts, missing_data_ends) {

  rmarkdown::render(
    here("report_files", "BWD_report_word.Rmd"),
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
                         "\\", project, "\\", deployment, "\\", deployment, "_beaked_whale_summary_", Sys.Date(), ".docx")
  )
}

# render report based on parameters set above
render_BWD_report(project, deployment, metadata, hourly, missing_data, missing_data_starts, missing_data_ends)
