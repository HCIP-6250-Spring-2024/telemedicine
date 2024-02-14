#-------------------------------------------------------------------------
# Install and load libraries
#-------------------------------------------------------------------------
# Install required packages (uncomment following lines and only run once)
install.packages("googledrive")
install.packages("glue")
install.packages("tidyr")
install.packages("readxl")
install.packages("zoo")

# Load required libraries (run every time you open file)
library(googledrive)
library(glue)
library (tidyr)
library(readxl)
library(zoo)

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

total_mcaid <- mcaid1 %>%
  group_by(State, Year) %>%
  summarise("Total Medicaid Telehealth Visits" = sum(ServiceCount, na.rm = TRUE))

#-------------------------------------------------------------------------
# Change State column to State Name to prepare for merge
#-------------------------------------------------------------------------

total_mcaid <- total_mcaid %>%
  rename(`State Name` = State)

#-------------------------------------------------------------------------
# Merge total_mcaid onto merged_data based on State Name and Year columns
#-------------------------------------------------------------------------
merged_data <- merge(merged_data, total_mcaid, by = c("State Name", "Year"), all.x = TRUE)
