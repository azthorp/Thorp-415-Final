# Thorp-415-Final
# Oʻahu Crime Explorer

A Shiny web application for visualizing and analyzing reported crime incidents across the island of Oʻahu using geocoded data from the Honolulu Police Department.

## Project Overview

The Oʻahu Crime Explorer was built to explore recent crime trends on the island using publicly available data.

This project allows users to:

- View individual crime incidents on an interactive map
- Filter crimes by year and type
- Examine trends by time of day, day of week, and over time
- Access a searchable data table
- Understand the broader social narrative through visual and geographic insight

## Data Source

The core dataset comes from the [Honolulu Police Department's Open Data Portal](https://data.honolulu.gov/Public-Safety/HPD-Crime-Incidents/vg88-5rn5/about_data), which includes individual crime reports with fields like type, date, time, and address.

## Geocoding Process

The dataset originally contained street addresses without geographic coordinates. To enable spatial analysis, we performed geocoding, converting text-based addresses into latitude and longitude values. This was achieved using the following steps:

1. **Data Cleaning**: Removed missing or malformed addresses.
2. **Address Concatenation**: Combined fields such as street, city, and ZIP to create full geocodable addresses.
3. **Batch Geocoding**: Used the OpenCage Geocoder API to process the addresses in batches.
4. **Filtering**: Filtered out results with low confidence or missing coordinates.
5. **Validation**: Mapped sample outputs to confirm correct placement within Oʻahu boundaries.

The final output was a clean CSV file containing crime events along with their geocoded latitude and longitude, which powers the map in this app.

## Tools & Libraries

- **R Shiny**: Interactive web framework
- **Leaflet**: Mapping library for spatial data
- **dplyr**: Data transformation and filtering
- **ggplot2**: Data visualization
- **DT**: Interactive data tables

## Features

### Interactive Map

- Filter by year and type of crime
- Click on any marker to see date, type, and address
- Map rendered with Leaflet and styled for clarity

### Crime Statistics & Visualizations

- **Top Crimes**: Bar chart of most common crime types
- **Crime Timelines**: Monthly trend per crime type (filtered to April 2025)
- **Time of Day**: Histogram of incidents by hour (peak at 2 PM, lowest at 4 AM)
- **Day of Week**: Crime frequency by weekday

### Data Table

- Full searchable and sortable table of crime records

## Credits

- Data: [Honolulu Police Department](https://data.honolulu.gov/)
