#-------------------------------------------------------------------------
# Install and load libraries
#-------------------------------------------------------------------------
#Install required packages (uncomment following lines and only run once)
#install.packages("glue")
#install.packages("tidyr")
#install.packages("googledrive")
#install.packages("readxl")
#install.packages("zoo")
#install.packages("dplyr")
#install.packages("reshape2")

# Load required libraries (run every time you open file)
library(tidyverse)
library(googledrive)
library(glue)
library (tidyr)
library(readxl)
library(zoo)
#library(dplyr)
library(scales)
library(reshape2)



#Read csv data file
df <- read.csv("final_dataset_v2.csv")

# Use dim() to find the dimension of the data set
dim(df)

# Use names() to find the names of the variables from the data set
names(df)

# Calculate total Medicare visits for each year
Mcare_visits_per_year <- aggregate(Total.Medicare.Visits ~ Year, data = df, FUN = sum)

# Calculate total Medicare  tele visits for each year
Mcare_tele_per_year <- aggregate(Total.Medicare.Telehealth.Visits ~ Year, data = df, FUN = sum)

# Calculate total Medicare in person visits for each year
Mcare_inperson_per_year <- aggregate(Total.Medicare.In.Person.Visits ~ Year, data = df, FUN = sum)


# Print the result
print(Mcare_visits_per_year)
print(Mcare_tele_per_year)
print(Mcare_inperson_per_year)

#------------------------------------------

# Plot of total Medicare visits per year
p1 <- ggplot(Mcare_tele_per_year, aes(x = as.factor(Year), y = Total.Medicare.Telehealth.Visits, fill = as.factor(Year))) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = round(Total.Medicare.Telehealth.Visits, 2)), vjust = -0.5) +  # Add text labels for bar heights
  labs(x = "Year", y = "Total Medicare Telehealth Visits (in millions) ", title = "Total Medicare Telehealth Visits Per Year ") +
  scale_fill_manual(values = c("2019" = "skyblue", "2020" = "lightgreen", "2021" = "grey"))+ 
  scale_y_continuous(labels = comma_format(scale = 1e-6))+
  theme_minimal()+labs(fill = "Year")
print(p1)



#-----------------------------

# Check for null values in the "Total Medicaid Visits" column
null_values <- is.na(df$Total.Medicaid.Telehealth.Visits)

# Count the number of null values
num_null_values <- sum(null_values)

# Print the result
print(num_null_values)

# Replace null values with 0 in the "Total Medicaid Visits" column
df$Total.Medicaid.Telehealth.Visits[is.na(df$Total.Medicaid.Telehealth.Visits)] <- 0

# Calculate total Medicaid visits for each year
Maid_televisits_per_year <- aggregate(Total.Medicaid.Telehealth.Visits ~ Year, data = df, FUN = sum)

# Print the result
print(Maid_televisits_per_year)

# Plot of total Medicaid tele health visits per year
p2 <- ggplot(Maid_televisits_per_year, aes(x = as.factor(Year), y =Total.Medicaid.Telehealth.Visits, fill = as.factor(Year))) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = round(Total.Medicaid.Telehealth.Visits, 2)), vjust = -0.5) +  # Add text labels for bar heights
  labs(x = "Year", y = "Total Medicaid telehealth Visits (in millions) ", title = "Total Medicaid Telehealth Visits Per Year ") +
  scale_fill_manual(values = c("2019" = "skyblue", "2020" = "lightgreen", "2021" = "grey"))+ 
  scale_y_continuous(labels = comma_format(scale = 1e-6))+
  theme_minimal() + labs(fill = "Year")
print(p2)




#--------------------------------------------------------------------------------------
# Plot a grouped bar graph for Medicare Inperson and Telehealth visits in each Year
#--------------------------------------------------------------------------------------

# Combine both datasets into one
combined_data_Mcare <- merge(Mcare_tele_per_year, Mcare_inperson_per_year, by = "Year")
print(combined_data_Mcare)

# Reshape the data for plotting
combined_data_Mcare <- reshape2::melt(combined_data_Mcare, id.vars = "Year", variable.name = "Type", value.name = "Visits")
print(combined_data_Mcare)

# Calculate the maximum y-axis value
max_y <- max(na.omit(combined_data_Mcare$Visits)) #removed/1e6
print(max_y)
#------------------------------
# Convert Year to factor
combined_data_Mcare$Year <- as.factor(combined_data_Mcare$Year)

# Calculate the maximum y-axis value
max_y <- max(combined_data_Mcare$Visits) * 1.1  # Adjust the multiplier as needed


plot_Mcare <- ggplot(combined_data_Mcare, aes(x = Year, y = Visits, fill = Type)) +
  geom_bar(stat = "identity", position = "dodge") +
  #geom_text(aes(label = round(Visits, 2)), vjust = -0.5) +  # Add text labels for bar heights
  labs(x = "Year", y = "Total Visits (in millions)", title = "Total Medicare In-Person and Telehealth Visits Per Year") +
  scale_fill_manual(values = c("Total.Medicare.Telehealth.Visits" = "red", "Total.Medicare.In.Person.Visits" = "lightblue")) +
  theme_minimal() +
  scale_y_continuous(labels = comma_format(scale = 1e-6), expand = c(0, 0), limits = c(0, max_y))  # Set y-axis limits and expand

# Print the plot
  print(plot_Mcare)
  
  #--------------------------------------------------------------------------------------
  # Plot a grouped bar graph for Medicare and Medicaid Telehealth visits in each Year
  #--------------------------------------------------------------------------------------
  
  # Combine both datasets into one
  combined_data <- merge(Mcare_tele_per_year, Maid_televisits_per_year, by = "Year")
  print(combined_data)

  # Reshape the data for plotting
  combined_data <- reshape2::melt(combined_data, id.vars = "Year", variable.name = "Type", value.name = "Visits")
  print(combined_data)
  

  #------------------------------
  # Convert Year to factor
  combined_data$Year <- as.factor(combined_data_Mcare$Year)
  
  # Calculate the maximum y-axis value
  max_y <- max(combined_data$Visits) * 1.1  # Adjust the multiplier as needed
  
  
  plot_tele <- ggplot(combined_data, aes(x = Year, y = Visits, fill = Type)) +
    geom_bar(stat = "identity", position = "dodge") +
    #geom_text(aes(label = round(Visits, 2)), vjust = -0.5) +  # Add text labels for bar heights
    labs(x = "Year", y = "Total Visits (in millions)", title = "Total Medicare and Medicaid Telehealth Visits Per Year") +
    scale_fill_manual(values = c("Total.Medicare.Telehealth.Visits" = "grey", "Total.Medicaid.Telehealth.Visits" = "lightgreen")) +
    theme_minimal() +
    scale_y_continuous(labels = comma_format(scale = 1e-6), expand = c(0, 0), limits = c(0, max_y))  # Set y-axis limits and expand
  
  # Print the plot
  print(plot_tele)







