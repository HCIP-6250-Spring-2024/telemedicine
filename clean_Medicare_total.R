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
# Find and read in 2021 Total Medicare Beneficiary file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the 2021 Medicare Total CSV  CSV file
file <- drive_find("total_medicare_ben_2021.csv")

# Create the file path to Google drive file location to download the file
total21_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(total21_id),overwrite = TRUE)

# Read in the downloaded file
total21 <- read.csv("total_medicare_ben_2021.csv")

#-------------------------------------------------------------------------
# Transform 2021 Total Medicare Beneficiary file
#-------------------------------------------------------------------------
# Rename Location to State Name to match merged file
total21 <- total21 %>%
  rename(`State Name` = Location)

# Add year column to total21 to prepare for merge
total21$Year = 2021

# Drop commas and change total to Numeric
total21$Total.Medicare.Enrollment <- gsub(",", "", total21$Total.Medicare.Enrollment)
total21$Total.Medicare.Enrollment.2021 <- as.numeric(total21$Total.Medicare.Enrollment)

# Subset dataframe to include State Name, Year and Total.Medicare.Enrollment
total21 <- total21[, c("State Name", "Year", "Total.Medicare.Enrollment")]

#-------------------------------------------------------------------------
# Find and read in 2020 Total Medicare Beneficiary file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the 2020 Medicare Total CSV  CSV file
file <- drive_find("total_medicare_ben_2020.csv")

# Create the file path to Google drive file location to download the file
total20_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(total20_id),overwrite = TRUE)

# Read in the downloaded file
total20 <- read.csv("total_medicare_ben_2020.csv")

#-------------------------------------------------------------------------
# Transform and Merge 2020 Total Medicare Beneficiary file into Merged file
#-------------------------------------------------------------------------
# Rename Location to State Name to match merged file
total20 <- total20 %>%
  rename(`State Name` = Location)

# Add year column to total20 to prepare for merge
total20$Year = 2020

# Drop commas and change total to Numeric
total20$Total.Medicare.Enrollment <- gsub(",", "", total20$Total.Medicare.Enrollment)
total20$Total.Medicare.Enrollment.2020 <- as.numeric(total20$Total.Medicare.Enrollment)

# Subset total20 to include State Name, Year and Total.Medicare.Enrollment
total20 <- total20[, c("State Name", "Year", "Total.Medicare.Enrollment")]

# Merge total20 onto total21 based on State Name and Year columns. Rename to merged_data.
total_mcare <- rbind(total21, total20)

#-------------------------------------------------------------------------
# Find and read in 2019 Total Medicare Beneficiary file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the 2019 Medicare Total CSV file
file <- drive_find("total_medicare_ben_2019.csv")

# Create the file path to Google drive file location to download the file
total19_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(total19_id),overwrite = TRUE)

# Read in the downloaded file
total19 <- read.csv("total_medicare_ben_2019.csv")

#-------------------------------------------------------------------------
# Transform and Merge 2019 Total Medicare Beneficiary file into Merged file
#-------------------------------------------------------------------------
# Rename Location to State Name to match merged file
total19 <- total19 %>%
  rename(`State Name` = Location)

# Add year column to total19 to prepare for merge
total19$Year = 2019

# Drop commas and change total to Numeric
total19$Total.Medicare.Enrollment <- gsub(",", "", total19$Total.Medicare.Enrollment)
total19$Total.Medicare.Enrollment.2019 <- as.numeric(total19$Total.Medicare.Enrollment)

# Subset total19 to include State Name, Year and Total.Medicare.Enrollment
total19 <- total19[, c("State Name", "Year", "Total.Medicare.Enrollment")]

# Append total19 onto merge_data
total_mcare<- rbind(total_mcare, total19)

#-------------------------------------------------------------------------
# Export Medicare Total file to Google Drive folder
#-------------------------------------------------------------------------
# Define the file name for saving the new file
output_file_name <- "total_mcare_final.csv"

# Export the total_mcaid dataframe to a CSV file
write.csv(total_mcare, file = output_file_name, row.names = FALSE)

# Upload the saved file to Google Drive in a specific folder
drive_upload(
  media = output_file_name,
  path = as_id("1jy4CpDVxomNNladCeg6OuZ9r1nn4oDZQ"),
  name = output_file_name,
  type = "text/csv",
  overwrite = TRUE,
)
