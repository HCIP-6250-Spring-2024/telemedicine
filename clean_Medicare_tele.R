#-------------------------------------------------------------------------
# Install and load libraries
#-------------------------------------------------------------------------
# Install required packages (uncomment following lines and only run once)
# install.packages("googledrive")
# install.packages("glue")
# install.packages("tidyr")
# install.packages("readxl")
# install.packages("zoo")
# install.packages("dplyr")

# Load required libraries (run every time you open file)
library(googledrive)
library(glue)
library (tidyr)
library(readxl)
library(zoo)
library(dplyr)

#-------------------------------------------------------------------------
# Authenticate and authorize access to Google Drive to access data files
#-------------------------------------------------------------------------
drive_auth()

#-------------------------------------------------------------------------
# Find and read in Medicare FFS file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "xlsx")

# Find the Medicare FFS XLSX file
file1 <- drive_find("medicare-ffs-telehealth-trends.xlsx")

# Create the file path to Google drive file location to download the file
mcare_tele_id <- glue("https://drive.google.com/open?id=",file1$id)

# Download the file from Google drive
drive_download(file=as_id(mcare_tele_id),overwrite = TRUE)

# Read in the downloaded file
mcare_tele <- read_xlsx("medicare-ffs-telehealth-trends.xlsx")

#-------------------------------------------------------------------------
# Clean Medicare Telehealth data
#-------------------------------------------------------------------------
# Rename Location to State Name to match merged file
mcare_tele <- mcare_tele %>%
  rename('Total Medicare Visits' = 'Total Visits',
         'Total Medicare Telehealth Visits' = 'Telehealth Visits', 
         'Total Medicare In-Person Visits' = 'In Person Visits',
         'Total Medicare Behavioral PCP Telehealth Visits' = 'Behavioral Health Primary Care Telehealth Visit',
         'Total Medicare Behavioral PCP In-Person Visits' = 'Behavioral Health Primary Care In-Person Visit')

# Subset mcare_tele to only include relevant variables
mcare_tele <- mcare_tele[, c("State Name", "Year", "Total Medicare Visits", "Total Medicare Telehealth Visits",
                   "Total Medicare In-Person Visits", "Total Medicare Behavioral PCP Telehealth Visits",
                   "Total Medicare Behavioral PCP In-Person Visits")]

#-------------------------------------------------------------------------
# Export Medicare Telehealth file to Google Drive folder
#-------------------------------------------------------------------------
# Define the file name for saving the new file
output_file_name <- "mcare_tele_final.csv"

# Export the total_mcaid dataframe to a CSV file
write.csv(mcare_tele, file = output_file_name, row.names = FALSE)

# Upload the saved file to Google Drive in a specific folder
drive_upload(
  media = output_file_name,
  path = as_id("1jy4CpDVxomNNladCeg6OuZ9r1nn4oDZQ"),
  name = output_file_name,
  type = "text/csv",
  overwrite = TRUE,
)
