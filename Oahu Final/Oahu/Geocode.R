library(tidygeocoder)
library(dplyr)
library(readr)

crime_data <- read_csv("HPD_Crime_Incidents_20250505.csv")

crime_data_clean <- crime_data %>%
  filter(!is.na(BlockAddress) & BlockAddress != "") %>%
  mutate(full_address = paste(BlockAddress, "Honolulu, HI"))

# Total records
n <- nrow(crime_data_clean)
chunk_size <- 500

# Create empty list to store results
all_results <- list()

for (i in seq(1, n, by = chunk_size)) {
  message("Processing rows ", i, " to ", min(i + chunk_size - 1, n))
  
  # Slice the chunk
  chunk <- crime_data_clean[i:min(i + chunk_size - 1, n), ]
  
  # Geocode
  result <- tryCatch({
    geocode(chunk, address = full_address, method = "osm", lat = latitude, long = longitude)
  }, error = function(e) {
    message("Error in chunk ", i, ": ", e$message)
    return(NULL)
  })
  
  if (!is.null(result)) {
    all_results[[length(all_results) + 1]] <- result
    Sys.sleep(1)
  }
}

# Combine and write to CSV
final_geocoded <- bind_rows(all_results)
write_csv(final_geocoded, "geocoded_crime_data_full.csv")
