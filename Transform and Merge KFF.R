#-------------------------------------------------------------------------
# Install and load libraries
#-------------------------------------------------------------------------
# Install required packages (only run once)
install.packages("googledrive")
install.packages("glue")
install.packages("tidyr")
install.packages("readxl")

# Load required libraries (run every time you open file)
library(googledrive)
library(glue)
library (tidyr)
library(readxl)

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

#-------------------------------------------------------------------------
# Find and read in Medicare FFS file
#-------------------------------------------------------------------------
# List files in your Google Drive
drive_find(type = "xlsx")

# Find the Medicare FFS XLSX file
file1 <- drive_find("medicare-ffs-telehealth-trends.xlsx")

# Create the file path to Google drive file location to download the file
med_id <- glue("https://drive.google.com/open?id=",file1$id)

# Download the file from Google drive
drive_download(file=as_id(med_id),overwrite = TRUE)

# Read in the downloaded file
med <- read_xlsx("medicare-ffs-telehealth-trends.xlsx")

#-------------------------------------------------------------------------
# Merge KFF and Medicare FFS tables
#-------------------------------------------------------------------------
merged_data <- merge(med, kff_final, by = "State Name", all = TRUE)
