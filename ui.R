library(leaflet)
library(shiny)



navbarPage("Warehouse Determination", id="nav",
           
           tabPanel("Interactive map",
                    div(class="outer",
                        
                        tags$head(
                          # Include our custom CSS
                          includeCSS("styles.css"),
                          includeScript("gomap.js")
                        ),
                        
                        # If not using custom CSS, set height of leafletOutput to a number instead of percent
                        leafletOutput("map", width="100%", height="100%"),
                        
                        # Shiny versions prior to 0.11 should use class = "modal" instead.
                        absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE,
                                      draggable = TRUE, top = 60, left = 20, right = "auto", bottom = "auto",
                                      width = 330, height = "auto",
                                      h3("Contol Panel"),
                                      radioButtons("sample_or_own","I Want to use sample data.",
                                                   choices = c("Yes","No"),
                                                   selected = "No",
                                                   inline=T),
                                      conditionalPanel("input.sample_or_own == 'No'",
                                      h3("Download "),
                                      downloadButton("downloadData", "Download the File Template"), 
                                      fileInput("file1", "Choose CSV File",
                                                accept = c(
                                                  "text/csv",
                                                  "text/comma-separated-values,text/plain",
                                                  ".csv")
                                      )),
                                      
                                      tags$hr(),
                                      sliderInput(inputId = "no_of_wh",label = "No of Warehouse",value=4,min = 1,max=10),
                                      numericInput("seed","Seed for K-Means",100,min=0,max=101),
                                      actionButton("run_cluster","Run Clustering"),
                                      tags$hr(),
                                      actionButton("find_cog","Find COG Locations")
                                      
                                      
                        )
                        
                    )
           )
           
           # tabPanel("Data explorer",
           #          fluidRow(
           #            column(3,
           #                   selectInput("states", "States", c("All states"="", structure(state.abb, names=state.name), "Washington, DC"="DC"), multiple=TRUE)
           #            ),
           #            column(3,
           #                   conditionalPanel("input.states",
           #                                    selectInput("cities", "Cities", c("All cities"=""), multiple=TRUE)
           #                   )
           #            ),
           #            column(3,
           #                   conditionalPanel("input.states",
           #                                    selectInput("zipcodes", "Zipcodes", c("All zipcodes"=""), multiple=TRUE)
           #                   )
           #            )
           #          ),
           #          fluidRow(
           #            column(1,
           #                   numericInput("minScore", "Min score", min=0, max=100, value=0)
           #            ),
           #            column(1,
           #                   numericInput("maxScore", "Max score", min=0, max=100, value=100)
           #            )
           #          ),
           #          hr(),
           #          DT::dataTableOutput("ziptable")
           # ),
           
)