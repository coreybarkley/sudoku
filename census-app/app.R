library(shiny)
library(bslib)
library(maps)
library(mapproj)

source("helpers.R")
counties <- readRDS("data/counties.rds")
color <- c(
	"Percent White" = "white",
	"Percent Black" = "black",
	"Percent Hispanic" = "green",
	"Percent Asian" = "yellow"
)

make_theme <- function(dark = TRUE) {
	if (dark) {
		bs_theme(
			bg = "#0d0d0f",
			fg = "#93a3af",
			primary = "red",
			secondary = "red",
			base_font = font_google("Comic Neue")
		)
	} else {
		bs_theme(
			bg = "#ffffff",
			fg = "#0d0d0f",
			primary = "red",
			secondary = "red",
			base_font = font_google("Comic Neue")
		)
	}
}

ui <- page_sidebar(
	tags$head(tags$script(HTML(
		"window.addEventListener('message',function(e) {
			if (!e.data || e.data.type !== 'theme') return;
			Shiny.setInputValue(
				'externalDarkMode',
				!!e.data.dark,
				{priority: 'event'}
			);
		});"
	))),

	# theme = make_theme(FALSE),
	theme = make_theme(TRUE),

	title = "censusVis",

	sidebar = sidebar(
		helpText(
			"Create demographic maps with information from the 2010 US Census."
		),
		selectInput(
			inputId = "var",
			label = "Choose a variable to display",
			choices = c(
				"Percent White",
				"Percent Black",
				"Percent Hispanic",
				"Percent Asian"
			),
			selected = "Percent White"
		),
		sliderInput(
			inputId = "range",
			label = "Range of interest:",
			min = 0,
			max = 100,
			value = c(0, 100)
		)
	),

	card(plotOutput("map"))
)

server <- function(input, output, session) {
	observeEvent(input$externalDarkMode, {
		session$setCurrentTheme(make_theme(isTRUE(input$externalDarkMode)))
	})

	output$map <- renderPlot({
		percent_map(
			counties[, str_to_lower(str_remove(input$var, "Percent "))],
			color[input$var],
			input$var,
			input$range[1],
			input$range[2]
		)
	})
}

shinyApp(ui, server)
