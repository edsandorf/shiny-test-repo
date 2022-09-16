#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(DBI)
library(pool)
library(tibble)
library(config)
library(RMariaDB)

# Get the connection details
db_config <- config::get("dataconnection")

# Set up the pool for effective handling of multiple connections
pool <- pool::dbPool(
  drv = RMariaDB::MariaDB(),
  dbname = db_config$dbname,
  host = db_config$host,
  username = db_config$username,
  password = db_config$password,
  ssl.key = db_config$ssl.key,
  ssl.cert = db_config$ssl.cert,
  ssl.ca = db_config$ssl.ca
)

# Define UI for application that draws a histogram
ui <- fluidPage(
    # Application title
    titlePanel("Test DB submission"),

    fluidRow(
      shiny::textInput("id", label = "Input a random string")
    ),
    fluidRow(
      actionButton("submit", "Submit to DB")
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

  # Observe event
  observeEvent(input$submit, {
    dbWriteTable(
      conn = pool,
      name = "test",
      value = tibble(
        timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
        id = input$id
      ),
      append = TRUE
    )
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
