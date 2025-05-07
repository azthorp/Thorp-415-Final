library(shiny)
library(leaflet)
library(dplyr)
library(ggplot2)
library(DT)

crime_data <- read.csv("geocoded_crime_data_full.csv")
crime_data$Date <- as.POSIXct(crime_data$Date, format = "%m/%d/%Y %I:%M:%S %p")
crime_data$Month <- format(crime_data$Date, "%Y-%m")
crime_data$Hour <- format(crime_data$Date, "%H")

# ---- UI ----
ui <- navbarPage("Oʻahu Crime Explorer",
                 tabPanel("About",
                          fluidPage(
                            tags$head(
                              tags$style(HTML(".hero-section {
                                background-image: url('HonoluluPoliceCar.jpg');
                                background-size: cover;
                                background-position: center;
                                height: 400px;
                                position: relative;
                              }
                              .hero-overlay {
                                background: linear-gradient(to bottom, rgba(0,0,0,0.6), rgba(255,255,255,1));
                                height: 100%;
                                width: 100%;
                                position: absolute;
                                top: 0;
                                left: 0;
                              }
                              .hero-content {
                                position: relative;
                                color: white;
                                padding: 150px 30px 30px 30px;
                                font-size: 24px;
                                text-shadow: 1px 1px 4px black;
                              }
                              .about-text, .map-description, .stat-description {
                                padding: 30px;
                                font-size: 18px;
                                line-height: 1.7em;
                              }
                              .scenic-background {
                                background-image: url('ScenicPicture.jpg');
                                background-size: cover;
                                background-position: center;
                                background-repeat: no-repeat;
                                background-attachment: fixed;
                                position: relative;
                                padding: 20px;
                              }
                              .crime-banner {
                                background-image: url('CrimeTape.jpg');
                                image-rendering: auto;
                                filter: brightness(1.1) contrast(1.05);
                                background-size: cover;
                                background-position: center;
                                height: 300px;
                                position: relative;
                              }
                              .crime-overlay {
                                background: linear-gradient(to bottom, rgba(0,0,0,0.4), rgba(255,255,255,0.9));
                                height: 100%;
                                width: 100%;
                                position: absolute;
                                top: 0;
                                left: 0;
                              }
                              .crime-header {
                                position: relative;
                                color: white;
                                padding: 120px 30px 30px 30px;
                                font-size: 24px;
                                text-shadow: 1px 1px 4px black;
                              }
                              .map-filters {
                                display: flex;
                                flex-wrap: wrap;
                                gap: 20px;
                                margin: 20px 0;
                                background-color: rgba(255,255,255,0.85);
                                padding: 15px;
                                border-radius: 5px;
                              }
                              .map-description {
                                background-color: rgba(255,255,255,0.85);
                                border-radius: 8px;
                                padding: 20px;
                                margin-top: 20px;
                              }"))
                            ),
                            div(class = "hero-section",
                                div(class = "hero-overlay"),
                                div(class = "hero-content",
                                    h2("Oʻahu Crime Overview")
                                )
                            ),
                            div(class = "about-text",
                                h3("About This Project"),
                                p("This Shiny application explores recent crime incidents across the island of Oʻahu using open data provided by the Honolulu Police Department. It was created to help contextualize public perceptions of crime by offering interactive visualizations and analyses grounded in data."),
                                p("Motivated by recent surveys indicating a growing concern over crime in Hawaiʻi, this project seeks to answer: Is crime really getting worse, or is perception outpacing reality? We aim to provide clarity by visualizing trends, hotspots, and types of crime reported in recent years."),
                                h4("Project Goals"),
                                tags$ul(
                                  tags$li("Map and visualize crime incidents across Oʻahu using geocoded locations."),
                                  tags$li("Provide interactive filtering by year and type of crime."),
                                  tags$li("Display statistical summaries to highlight the most common crimes and patterns over time."),
                                  tags$li("Compare media narratives to empirical trends, with insights from research by the Hawaiʻi Crime Lab at UH Mānoa.")
                                ),
                                h4("Approach"),
                                p("We started by cleaning and geocoding thousands of individual crime records to add location-based insights. From there, we developed filters and visualizations that allow users to explore crime by year, category, time of day, and frequency. The project is structured around both spatial and temporal trends, making it easy to detect patterns and anomalies."),
                                p("By combining interactive data tools with current research and a critical look at how crime is reported and understood, this application helps users make informed conclusions about crime on Oʻahu.")
                            )
                          )
                 ),
                 
                 tabPanel("Map",
                          fluidPage(
                            div(class = "scenic-background",
                                div(class = "map-filters",
                                    checkboxGroupInput("year_filter", "Select Year:",
                                                       choices = sort(unique(format(crime_data$Date, "%Y"))),
                                                       selected = sort(unique(format(crime_data$Date, "%Y")))),
                                    selectInput("type_filter", "Select Crime Type:",
                                                choices = unique(crime_data$Type),
                                                selected = unique(crime_data$Type),
                                                multiple = TRUE)
                                ),
                                leafletOutput("crime_map", height = 700, width = "100%"),
                                div(class = "map-description",
                                    p("This interactive map shows individual reported crime incidents across Oʻahu. Users can filter by both year and crime type using the controls above. When clicking on any dot, a popup will show the specific crime type, date, and address of the incident. This visualization enables geographic pattern recognition and allows viewers to inspect specific hotspots and outliers.")
                                )
                            )
                          )
                 ),
                 
                 tabPanel("Statistics",
                          fluidPage(
                            div(class = "crime-banner",
                                div(class = "crime-overlay"),
                                div(class = "crime-header",
                                    h2("Crime Statistics & Trends")
                                )
                            ),
                            selectInput("stat_view", "Select Visualization:",
                                        choices = c("Top Crimes", "Crime Timelines", "Time of Day", "Day of Week"),
                                        selected = "Top Crimes"),
                            
                            conditionalPanel(
                              condition = "input.stat_view == 'Top Crimes'",
                              plotOutput("top_crimes"),
                              div(class = "stat-description",
                                  p("The bar chart above displays the most frequently reported types of crime across Oʻahu. Theft/Larceny overwhelmingly dominates all other crime categories, followed by vandalism and assault. This view highlights the types of crime that make up the majority of incidents in the dataset.")
                              )
                            ),
                            
                            conditionalPanel(
                              condition = "input.stat_view == 'Crime Timelines'",
                              selectInput("timeline_type", "Select Crime Type:", choices = unique(crime_data$Type)),
                              plotOutput("timeline_plot"),
                              div(class = "stat-description",
                                  p("This timeline displays how reported crime varies by month over time. By selecting a specific crime type, users can observe seasonal or yearly trends. The data shown is restricted to crimes up to April 2025, allowing for clear comparisons across recent full months.")
                              )
                            ),
                            
                            conditionalPanel(
                              condition = "input.stat_view == 'Time of Day'",
                              plotOutput("hourly_plot"),
                              div(class = "stat-description",
                                  p("This bar chart illustrates when crimes tend to happen throughout the day. Reported incidents spike in the early afternoon, peaking around 2:00 PM (14:00), while the lowest levels occur in the early morning around 4:00 AM. Understanding hourly patterns can be useful for crime prevention and resource allocation.")
                              )
                            ),
                            
                            conditionalPanel(
                              condition = "input.stat_view == 'Day of Week'",
                              plotOutput("weekday_plot"),
                              div(class = "stat-description",
                                  p("This chart explores which days of the week have the highest levels of reported crime. Based on the dataset, weekends tend to show lower crime activity. On the other hand, Mondays seem to be the peak day for crime activity.")
                              )
                            )
                          )
                 ),
                 
                 tabPanel("Data Table",
                          DTOutput("crime_table")
                 ),
                 
                 tabPanel("Sources",
                          fluidPage(
                            tags$ul(
                              tags$li(a("Honolulu Police Department Dataset (Socrata)", href = "https://data.honolulu.gov/Public-Safety/HPD-Crime-Incidents/vg88-5rn5/about_data")),
                              tags$li(a("Leaflet for R", href = "https://rstudio.github.io/leaflet/")),
                              tags$li(a("What Social Science Tells Us About Violent Crime On Oʻahu", href = "https://www.civilbeat.org/2025/03/what-social-science-tells-us-about-violent-crime-on-oahu/"))
                            )
                          )
                 )
)

# ---- Server ----
server <- function(input, output) {
  
  filtered_data <- reactive({
    req(input$type_filter, input$year_filter)
    
    crime_data %>%
      filter(Type %in% input$type_filter) %>%
      filter(!is.na(latitude) & !is.na(longitude)) %>%
      filter(format(as.Date(Date), "%Y") %in% input$year_filter)
  })
  
  output$crime_map <- renderLeaflet({
    leaflet(filtered_data()) %>%
      addTiles() %>%
      addCircleMarkers(~longitude, ~latitude, radius = 5, color = "red",
                       popup = ~paste("Type:", Type, "<br>Date:", Date, "<br>Address:", full_address))
  })
  
  output$top_crimes <- renderPlot({
    crime_data %>%
      count(Type, sort = TRUE) %>%
      ggplot(aes(x = reorder(Type, n), y = n)) +
      geom_bar(stat = "identity", fill = "steelblue") +
      coord_flip() +
      labs(title = "Top Reported Crime Types", x = "Crime Type", y = "Count")
  })
  
  output$timeline_plot <- renderPlot({
    req(input$timeline_type)
    crime_data %>%
      filter(Type == input$timeline_type) %>%
      filter(Month <= "2025-04") %>%
      count(Month) %>%
      ggplot(aes(x = as.Date(paste0(Month, "-01")), y = n)) +
      geom_line(color = "darkred", size = 1.2) +
      labs(title = paste("Monthly Crime Trend:", input$timeline_type),
           x = "Month", y = "Number of Incidents") +
      theme_minimal()
  })
  
  output$hourly_plot <- renderPlot({
    crime_data %>%
      count(Hour) %>%
      ggplot(aes(x = as.numeric(Hour), y = n)) +
      geom_bar(stat = "identity", fill = "darkblue") +
      scale_x_continuous(breaks = 0:23) +
      labs(title = "Crimes by Hour of Day", x = "Hour (24h)", y = "Frequency") +
      theme_minimal()
  })
  
  output$weekday_plot <- renderPlot({
    crime_data %>%
      mutate(Weekday = weekdays(Date)) %>%
      count(Weekday) %>%
      mutate(Weekday = factor(Weekday, levels = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))) %>%
      ggplot(aes(x = Weekday, y = n)) +
      geom_bar(stat = "identity", fill = "darkgreen") +
      labs(title = "Crimes by Day of Week", x = "Day", y = "Frequency") +
      theme_minimal()
  })
  
  output$crime_table <- renderDT({
    datatable(crime_data, options = list(pageLength = 10))
  })
}

# ---- Run App ----
shinyApp(ui, server)