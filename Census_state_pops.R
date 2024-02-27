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
# Find and read in 2019 Census State Population file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the 2019 Census Total CSV file
file <- drive_find("2019_Census_State_Populations.csv")

# Create the file path to Google drive file location to download the file
pop19_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(pop19_id),overwrite = TRUE)

# Read in the downloaded file
pop19 <- read.csv("2019_Census_State_Populations.csv")

#-------------------------------------------------------------------------
# Transform 2019 Census State Population file
#-------------------------------------------------------------------------
# Rename Name to State Name to match merged file
pop19 <- pop19 %>%
  rename(`State Name` = NAME)

# Add year column to pop19 to prepare for merge
pop19$Year = 2019

# Change population estimate to Numeric
pop19$POPESTIMATE2019 <- as.numeric(pop19$POPESTIMATE2019)

# Rename POPESTIMATE2019 to State Population
pop19 <- pop19 %>%
  rename(State_Population = POPESTIMATE2019)

# Subset total19 to include State Name, Year and Total.Medicare.Enrollment
pop19 <- pop19[, c("State Name", "Year", "State_Population")]

#-------------------------------------------------------------------------
# Find and read in 2020-2022 Census State Population file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the 2020-2022 Census Total CSV file
file <- drive_find("2020_2022_Census_State_Populations.csv")

# Create the file path to Google drive file location to download the file
pop20_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(pop20_id),overwrite = TRUE)

# Read in the downloaded file
pop20 <- read.csv("2020_2022_Census_State_Populations.csv")
pop21 <- read.csv("2020_2022_Census_State_Populations.csv")

#-------------------------------------------------------------------------
# Transform 2020-2022 Census State Population file for 2020
#-------------------------------------------------------------------------
# Rename Name to State Name to match merged file
pop20 <- pop20 %>%
  rename(`State Name` = NAME)

# Add year column to pop20 to prepare for merge
pop20$Year = 2020

# Change population estimate to Numeric
pop20$POPESTIMATE2020 <- as.numeric(pop20$POPESTIMATE2020)

# Rename POPESTIMATE2020 to State Population
pop20 <- pop20 %>%
  rename(State_Population = POPESTIMATE2020)

# Subset total19 to include State Name, Year and Total.Medicare.Enrollment
pop20 <- pop20[, c("State Name", "Year", "State_Population")]

# Bind 2019 and 2020 State Populations
state_pops <- rbind(pop19, pop20)

#-------------------------------------------------------------------------
# Transform 2020-2022 Census State Population file for 2021
#-------------------------------------------------------------------------
# Rename Name to State Name to match merged file
pop21 <- pop21 %>%
  rename(`State Name` = NAME)

# Add year column to pop20 to prepare for merge
pop21$Year = 2021

# Change population estimate to Numeric
pop21$POPESTIMATE2021 <- as.numeric(pop21$POPESTIMATE2021)

# Rename POPESTIMATE2020 to State Population
pop21 <- pop21 %>%
  rename(State_Population = POPESTIMATE2021)

# Subset total19 to include State Name, Year and Total.Medicare.Enrollment
pop21 <- pop21[, c("State Name", "Year", "State_Population")]

# Append pop21 to state_pops
state_pops <- rbind(state_pops, pop21)

#-------------------------------------------------------------------------
# Export State Populations file to Google Drive folder
#-------------------------------------------------------------------------
# Define the file name for saving the new file
output_file_name <- "state_populations_final.csv"

# Export the state_pops dataframe to a CSV file
write.csv(state_pops, file = output_file_name, row.names = FALSE)

# Upload the saved file to Google Drive in a specific folder
drive_upload(
  media = output_file_name,
  path = as_id("1jy4CpDVxomNNladCeg6OuZ9r1nn4oDZQ"),
  name = output_file_name,
  type = "text/csv",
  overwrite = TRUE,
)
