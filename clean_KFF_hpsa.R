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
# Find and read in KFF file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "csv")

# Find the Kaiser HSPA CSV file
file <- drive_find("kff_hpsa.csv")

# Create the file path to Google drive file location to download the file
kff_id <- glue("https://drive.google.com/open?id=",file$id)

# Download the file from Google drive
drive_download(file=as_id(kff_id),overwrite = TRUE)

# Read in the downloaded file
kff <- read.csv("kff_hpsa.csv")

#-------------------------------------------------------------------------
# Transform KFF file
#-------------------------------------------------------------------------
# Melt all columns into rows
kff_long <- t(kff)

# Convert the transposed data into a data frame
kff_final <- as.data.frame(kff_long)

# Assign column names
colnames(kff_final) <- kff_final[1, ]

# Remove the first row (which is now the column names)
kff_final <- kff_final[-1, ]

# Move the column with row names to the first column position
kff_final <- kff_final %>%
  mutate("State Name" = rownames(kff_final)) %>%
  select("State Name", everything())

# Set row names as numbers (assuming 'n' is the number of rows)
rownames(kff_final) <- 1:nrow(kff_final)

# Remove United States row from KFF dataset
kff_final <- kff_final[-1, ]

# Rename Dist..of.Columbia variable to match Medicare file
kff_final$`State Name` <- gsub("Dist\\.\\.of\\.Columbia", "District of Columbia", kff_final$`State Name`)

# Find and replace all periods between state names with space to match Medicare
kff_final$`State Name` <- gsub("\\.", " ", kff_final$`State Name`)

# Remove '%' character and convert Percent of Need Met to numeric 
kff_final$'Percent of Need Met' <- as.numeric(gsub("%", "", kff_hspa$'Percent of Need Met'))

# Convert the values in Percent of Need Met to decimal representation
kff_final$'Percent of Need Met' <- kff_final$'Percent of Need Met' / 100

# Find and replace all commas within Practicioners column and change to numeric
kff_final$`Practitioners Needed to Remove HPSA Designation` <- as.numeric(
  gsub(",", "", kff_final$`Practitioners Needed to Remove HPSA Designation`))

# Subset relevant columns
kff_final <- kff_final[c('State Name','Percent of Need Met', 'Practitioners Needed to Remove HPSA Designation')]

#-------------------------------------------------------------------------
# Export KFF file to Google Drive folder
#-------------------------------------------------------------------------
# Define the file name for saving the new file
output_file_name <- "kff_hspa_final.csv"

# Export the kff_hspa_final dataframe to a CSV file
write.csv(kff_final, file = output_file_name, row.names = FALSE)

# Upload the saved file to Google Drive in the Cleaned Data folder
drive_upload(
  media = output_file_name,
  path = as_id("1jy4CpDVxomNNladCeg6OuZ9r1nn4oDZQ"),
  name = output_file_name,
  type = "text/csv",
  overwrite = TRUE,
)
