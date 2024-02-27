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
# Find and read in 2021 Total Medicaid/Chip Beneficiary file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the 2021 Medicaid Total CSV  CSV file
file <- drive_find("2021_medicaid_enrollment.csv")

# Create the file path to Google drive file location to download the file
total21_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(total21_id),overwrite = TRUE)

# Read in the downloaded file
total21 <- read.csv("2021_medicaid_enrollment.csv")

#-------------------------------------------------------------------------
# Transform 2021 Total Medicare Beneficiary file
#-------------------------------------------------------------------------
# Rename Location to State Name to match merged file
total21 <- total21 %>%
  rename(`State Name` = Location)

# Add year column to total21 to prepare for merge
total21$Year = 2021

#-------------------------------------------------------------------------
# Find and read in 2020 Total Medicaid/Chip Beneficiary file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the 2021 Medicaid Total CSV  CSV file
file <- drive_find("2020_medicaid_enrollment.csv")

# Create the file path to Google drive file location to download the file
total20_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(total20_id),overwrite = TRUE)

# Read in the downloaded file
total20 <- read.csv("2020_medicaid_enrollment.csv")

#-------------------------------------------------------------------------
# Transform 2020 Total Medicare Beneficiary file and bind with 2021 file
#-------------------------------------------------------------------------
# Rename Location to State Name to match merged file
total20 <- total20 %>%
  rename(`State Name` = Location)

# Add year column to total20 to prepare for merge
total20$Year = 2020

# Bind total20 onto total21 and rename to total_mcaid
total_mcaid <- rbind(total21, total20)

#-------------------------------------------------------------------------
# Find and read in 2019 Total Medicaid/Chip Beneficiary file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the 2019 Medicaid Total CSV  CSV file
file <- drive_find("2019_medicaid_enrollment.csv")

# Create the file path to Google drive file location to download the file
total19_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(total19_id),overwrite = TRUE)

# Read in the downloaded file
total19 <- read.csv("2019_medicaid_enrollment.csv")

#-------------------------------------------------------------------------
# Transform 2019 Total Medicare Beneficiary file and bind with total_mcaid
#-------------------------------------------------------------------------
# Rename Location to State Name to match merged file
total19 <- total19 %>%
  rename(`State Name` = Location)

# Add year column to total19 to prepare for merge
total19$Year = 2019

# Bind total19 onto total_mcaid
total_mcaid <- rbind(total_mcaid, total19)

#-------------------------------------------------------------------------
# Export Medicaid Total file to Google Drive folder
#-------------------------------------------------------------------------
# Define the file name for saving the new file
output_file_name <- "total_mcaid_final.csv"

# Export the total_mcaid dataframe to a CSV file
write.csv(total_mcaid, file = output_file_name, row.names = FALSE)

# Upload the saved file to Google Drive in a specific folder
drive_upload(
  media = output_file_name,
  path = as_id("1jy4CpDVxomNNladCeg6OuZ9r1nn4oDZQ"),
  name = output_file_name,
  type = "text/csv",
  overwrite = TRUE,
)
