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
# Find and read in Medicaid/CHIP file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the Kaiser HSPA CSV file
file <- drive_find("MedicaidChip_Telehealth_Services.csv")

# Create the file path to Google drive file location to download the file
mcaid_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(mcaid_id),overwrite = TRUE)

# Read in the downloaded file
mcaid <- read.csv("MedicaidChip_Telehealth_Services.csv")

#-------------------------------------------------------------------------
# Transform Medicaid/CHIP dataframe
#-------------------------------------------------------------------------

# Create new dataframe from mcaid df for transformation
mcaid1 <- mcaid

# Change "-" values to 0
mcaid1$ServiceCount[mcaid1$ServiceCount == " -   "] <- 0

# Change DS values to 0 since they are < 11 rows and surpressed
mcaid1$ServiceCount[mcaid1$ServiceCount == " DS "] = 0

# Remove commas and change ServiceCount data type to numeric
mcaid1$ServiceCount <- gsub(",", "", mcaid1$ServiceCount)
mcaid1$ServiceCount <- as.numeric(mcaid1$ServiceCount)

# Change certain rows to NA since some rows are labelled as "unusable"
mcaid1$ServiceCount[mcaid1$DataQuality == "Unusable"] <- NA

# Change Month column to only have the month digits
mcaid1$Month <- substring(mcaid1$Month, 5, 6)

# Filter out rows with mcaid1$Year outside the range 2019-2021
mcaid1 <- mcaid1 %>%
  filter(Year >= 2019 & Year <= 2021)

# Filter out rows for Arkansas and Tennessee since their data is unusable
mcaid1 <- mcaid1 %>%
  filter(State != "Arkansas" & State != "Tennessee")

#-------------------------------------------------------------------------
# Impute the unusable NA values via Last Observed Carried Forward for the
# previous month within the same year, for the same Telehealth Type
#-------------------------------------------------------------------------

# Sort the dataset by State, Year, Month, and TelehealthType
mcaid1 <- mcaid1 %>%
  arrange(State, Year, Month, TelehealthType)

# Define a function for LOCF imputation within each group
impute_locf <- function(x) {
  na.locf(x, na.rm = FALSE)
}

# Apply LOCF imputation within each group defined by TelehealthType
mcaid1 <- mcaid1 %>%
  group_by(TelehealthType) %>%
  mutate(ServiceCount = impute_locf(ServiceCount)) %>%
  ungroup()

#-------------------------------------------------------------------------
# # Sum visits by State and Year
#-------------------------------------------------------------------------

total_mcaid_tele <- mcaid1 %>%
  group_by(State, Year) %>%
  summarise("Total Medicaid Telehealth Visits" = sum(ServiceCount, na.rm = TRUE))

#-------------------------------------------------------------------------
# Change State column to State Name to prepare for merge
#-------------------------------------------------------------------------

total_mcaid_tele <- total_mcaid_tele %>%
  rename(`State Name` = State)

#-------------------------------------------------------------------------
# Export Medicaid telehealth file to Google Drive folder
#-------------------------------------------------------------------------
# Define the file name for saving the new file
output_file_name <- "total_mcaid_tele_final.csv"

# Export the total_mcaid dataframe to a CSV file
write.csv(total_mcaid_tele, file = output_file_name, row.names = FALSE)

# Upload the saved file to Google Drive in a specific folder
drive_upload(
  media = output_file_name,
  path = as_id("1jy4CpDVxomNNladCeg6OuZ9r1nn4oDZQ"),
  name = output_file_name,
  type = "text/csv",
  overwrite = TRUE,
)
