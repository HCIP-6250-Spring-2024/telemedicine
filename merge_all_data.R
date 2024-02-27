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
# Find and read in Medicare Telehealth cleaned data file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the Kaiser HSPA CSV file
file <- drive_find("mcare_tele_final.csv")

# Create the file path to Google drive file location to download the file
mcare_tele_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(mcare_tele_id),overwrite = TRUE)

# Read in the downloaded file
mcare_tele <- read.csv("mcare_tele_final.csv", check.names=FALSE)

#-------------------------------------------------------------------------
# Find and read in State Populations cleaned data file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the Kaiser HSPA CSV file
file <- drive_find("state_populations_final.csv")

# Create the file path to Google drive file location to download the file
state_pops_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(state_pops_id),overwrite = TRUE)

# Read in the downloaded file
state_pops <- read.csv("state_populations_final.csv", check.names=FALSE)

#-------------------------------------------------------------------------
# Find and read in State Populations cleaned data file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the Kaiser HSPA CSV file
file <- drive_find("state_populations_final.csv")

# Create the file path to Google drive file location to download the file
state_pops_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(state_pops_id),overwrite = TRUE)

# Read in the downloaded file
state_pops <- read.csv("state_populations_final.csv", check.names=FALSE)

#-------------------------------------------------------------------------
# Find and read in Medicaid Telehealth cleaned data file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the Kaiser HSPA CSV file
file <- drive_find("total_mcaid_tele_final.csv")

# Create the file path to Google drive file location to download the file
mcaid_tele_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(mcaid_tele_id),overwrite = TRUE)

# Read in the downloaded file
mcaid_tele <- read.csv("total_mcaid_tele_final.csv", check.names=FALSE)

#-------------------------------------------------------------------------
# Find and read in Total Medicare Beneficiaries cleaned data file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the Kaiser HSPA CSV file
file <- drive_find("total_mcare_final.csv")

# Create the file path to Google drive file location to download the file
total_mcare_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(total_mcare_id),overwrite = TRUE)

# Read in the downloaded file
total_mcare <- read.csv("total_mcare_final.csv", check.names=FALSE)

#-------------------------------------------------------------------------
# Find and read in KFF cleaned data file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the Kaiser HSPA CSV file
file <- drive_find("kff_hspa_final.csv")

# Create the file path to Google drive file location to download the file
kff_hspa_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(kff_hspa_id),overwrite = TRUE)

# Read in the downloaded file
kff_hspa <- read.csv("kff_hspa_final.csv", check.names=FALSE)

#-------------------------------------------------------------------------
# Merge Data files
#-------------------------------------------------------------------------
# Merge total_mcare onto mcare_tele based on State Name and Year columns
merged_data <- merge(mcare_tele, total_mcare, 
                     by = c("State Name", "Year"), all.x = TRUE)

# Merge mcaid_tele onto merged_data based on State Name and Year columns
merged_data <- merge(merged_data, mcaid_tele, 
                     by = c("State Name", "Year"), all.x = TRUE)

# Merge state_pops onto merged_data based on State Name and Year columns
merged_data <- merge(merged_data, state_pops, 
                     by = c("State Name", "Year"), all.x = TRUE)

# Merge kff_hspa onto merged_data based on ONLY the State Name column
merged_data <- merge(merged_data, kff_hspa, 
                     by = "State Name", all.x = TRUE)
