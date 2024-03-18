# Format beaked whale presence table for submission to NOAA PACM

# J. Stanistreet updated 18 March 2024

################################################################

library(pacman)
pacman::p_load(tidyverse, lubridate, readxl)

##### EDIT INPUT INFORMATION #####

project = "DFO_MAR"
deployment = "EFC_2021_08"
sampling_rate = 256000
analysis_start <- as_date("2021-08-21") # first full day analyzed
analysis_end <- as_date("2022-08-12") # last full day analyzed

# if deployment included multiple sampling rates (e.g. AMAR G3) append_HF = TRUE
append_HF = FALSE

# if missing_data = TRUE, specify start and end date(s) of missing data period(s) (if false, this will be ignored) 
missing_data = FALSE

## use format c("YYYY-MM-DD", "YYYY-MM-DD")

missing_data_starts = c("2021-10-01", "2021-11-01")
missing_data_ends = c("2021-10-05", "2021-11-05")

##### EDIT METHODS INFORMATION IF NEEDED #####

# species analyzed (include all species searched for, even if not present in results)

species_list <- c("Ha","Mb","MmMe","Zc") # BWD codes for species included in analysis
species_labels <- c("NBWH","SOBW","MEME","GOBW") # PACM codes for species included in analysis

# standard methods information - usually won't change

analysis_period = 86400 # NOTE: we are summarizing all detection data per day for submission to PACM
n_detects = 'NA'
time_zone = 'UTC'
call_type = 'FMUS' # FMUS = frequency-modulated upsweep
detection_method = 'Triton/DFO TWD'
protocol_ref = 'Beslin & Stanistreet in prep.'
software = 'MATLAB'
software_version = 'R2020a'
min_freq = '0'
max_freq = sampling_rate/2
qc_proc = 'Archival'


################################################################

# Run lines below without editing

# input data: presence table
input_data <- read_excel(paste0(r"(R:\Science\CetaceanOPPNoise\CetaceanOPPNoise_4\PAM_analysis)", "\\", project, "\\", deployment, "\\", deployment, "_Beaked_Presence.xlsx"))

# clean up
names(input_data) = sub(".*_","",names(input_data))

# label species with PACM codes
species_list_named <- species_list
names(species_list_named) <-species_labels

# set up missing data periods if needed
if (missing_data){
  
  missing_dates_list <- mapply(seq.Date, as_date(missing_data_starts), as_date(missing_data_ends), by = 1, SIMPLIFY = FALSE)
  missing_dates <- as_date(unlist(missing_dates_list, use.names = FALSE))

  }

# append "_HF" to deployment name if needed
if (append_HF){ 
  
  unique_ID = str_c(deployment, "_HF")
  
} else {
  unique_ID = deployment
  
}

# format data
output <- input_data %>% 
  
  # add date column
  mutate(date_only = as_date(StartTime, format="%Y%m%d_%H%M%S")) %>% 
  
  # filter by specified analysis dates (in case partial days were present)
  filter(date_only >= analysis_start & date_only <= analysis_end) %>%
  
  # reformat
  pivot_longer(cols = any_of(species_list), names_to = "species", values_to = "presence") %>% 
  
  # add factor levels for species not present in data
  mutate(species = fct_expand(species, species_list)) %>% 
  
  # rename factor levels with PACM species codes
  mutate(species = fct_recode(species, !!!species_list_named)) %>%  
  
  # group by date and species, don't drop missing species
  group_by(date_only, species, .drop = F) %>% 
  
  # get daily presence or possible presence (counts if analysis was hourly)
  summarise(true_count = sum(presence == "1"), possible_count = sum(presence == '-1')) %>%
  
  ungroup() %>%
  
  # fill in rows for days with no detections
  complete(date_only = seq.Date(analysis_start,analysis_end, by="day"), 
           nesting(species), 
           fill = list(true_count = 0, possible_count = 0)) %>% 
    
  # add column with call presence specification using PACM codes
  mutate(call_presence = case_when(true_count > 0 ~ "D",
                                   true_count == 0 & possible_count > 0 ~ "P",
                                   true_count == 0 & possible_count == 0 ~ "N")) %>% 
    
  # if applicable, set call presence to 'M' during missing data periods
  { if (missing_data) mutate(., call_presence = case_when(date_only %in% missing_dates ~ "M",
                                                .default = call_presence)) else .} %>%
  
  ## format everything for PACM template 
  mutate(UNIQUE_ID = unique_ID,
         ANALYSIS_PERIOD_START_DATETIME = as.POSIXct(date_only),
         ANALYSIS_PERIOD_END_DATETIME = as.POSIXct(date_only+1),
         ANALYSIS_PERIOD_EFFORT_SECONDS = analysis_period,
         ANALYSIS_TIME_ZONE = time_zone) %>% 
  
  rename(SPECIES_CODE = species,
         ACOUSTIC_PRESENCE = call_presence) %>%
  
  mutate(N_VALIDATED_DETECTIONS = n_detects,
         CALL_TYPE_CODE = call_type,
         DETECTION_METHOD = detection_method,
         PROTOCOL_REFERENCE = protocol_ref,
         DETECTION_SOFTWARE_NAME = software,
         DETECTION_SOFTWARE_VERSION = software_version, 
         MIN_ANALYSIS_FREQUENCY_RANGE_HZ = min_freq,
         MAX_ANALYSIS_FREQUENCY_RANGE_HZ = max_freq,
         ANALYSIS_SAMPLING_RATE_HZ = 256000, #sampling_rate,
         QC_PROCESSING = qc_proc) %>% 
  
  # remove extra variables
  select(-true_count, -possible_count, -date_only) %>% 
  
  # put columns in correct order for output csv
  relocate(UNIQUE_ID, 
           ANALYSIS_PERIOD_START_DATETIME, 
           ANALYSIS_PERIOD_END_DATETIME, 
           ANALYSIS_PERIOD_EFFORT_SECONDS, 
           ANALYSIS_TIME_ZONE,
           SPECIES_CODE, 
           ACOUSTIC_PRESENCE, 
           N_VALIDATED_DETECTIONS, 
           CALL_TYPE_CODE, 
           DETECTION_METHOD, 
           PROTOCOL_REFERENCE, 
           DETECTION_SOFTWARE_NAME,
           DETECTION_SOFTWARE_VERSION, 
           MIN_ANALYSIS_FREQUENCY_RANGE_HZ, 
           MAX_ANALYSIS_FREQUENCY_RANGE_HZ, 
           ANALYSIS_SAMPLING_RATE_HZ,
           QC_PROCESSING)

# set up output file name
today <- format(Sys.Date(), format = "%Y%m%d")
output_csv_file <- str_c(r"(R:\\Science\\CetaceanOPPNoise\\CetaceanOPPNoise_4\\PAM_analysis)",
                         "\\", project, "\\", deployment, "\\", "DFOCA_", today, "_DETECTIONDATA_", unique_ID, ".csv")

# save csv
write_csv(output, output_csv_file)

