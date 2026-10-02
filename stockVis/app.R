# Load packages ----
library(shiny)
library(bslib)
library(quantmod)

# Source helpers ----
source("helpers.R")

# User interface ----
ui <- page_sidebar(
	theme = bs_theme(
		bg = "#0d0d0f",
		fg = "#93a3af",
		primary = "#93a3af",
		secondary = "#93a3af",
		base_font = font_google("Comic Neue")
	),
	title = "stockVis",
	sidebar = sidebar(
		helpText(
			"Select a stock to examine.

			Information will be collected from Yahoo finance."
		),
		textInput("symb", "Symbol", "SPY"),
		br(),
		checkboxInput(
			"log",
			"Plot y axis on log scale",
			value = FALSE
		),
		checkboxInput(
			"adjust",
			"Adjust prices for inflation",
			value = FALSE
		),
		br(),
		dateRangeInput(
			"dates",
			"Date range",
			start = "2013-01-01",
			end = as.character(Sys.Date())
		),
	),
	card(
		card_header("Price over time"),
		plotOutput("plot")
	)
)

# Server logic
server <- function(input, output) {
	dateMinInput <- reactive({
		input$dates[1]
	})
	dateMaxInput <- reactive({
		input$dates[2]
	})
	dataInput <- reactive({
		getSymbols(
			input$symb,
			src = "yahoo",
			from = dateMinInput(),
			to = dateMaxInput(),
			auto.assign = FALSE
		)
	})

	finalInput <- reactive({
		if (!input$adjust) {
			return(dataInput())
		}
		adjust(dataInput())
	})

	logInput <- reactive({
		input$log
	})

	output$plot <- renderPlot({
		chartSeries(
			finalInput(),
			theme = chartTheme("black"),
			type = "line",
			log.scale = logInput(),
			TA = NULL
		)
	})
}

# Run the app
shinyApp(ui, server)
