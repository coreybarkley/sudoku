library(shiny)
library(bslib)
make_theme <- function(dark = FALSE) {
	if (dark) {
		bs_theme(
			bg = "#0a0a0a", # body background
			fg = "#f3f4f6", # main text color
			primary = "#4b5563", # accent / buttons
			secondary = "#374151",
			base_font = font_google("Comic Neue")
		)
	} else {
		bs_theme(
			bg = "#ffffff", # body background
			fg = "#1f2937", # main text color
			primary = "#1f2937",
			secondary = "#cbd5e1",
			base_font = font_google("Comic Neue")
		)
	}
}

ui <- fluidPage(
	theme = make_theme(FALSE),
	"Hello, World!"
)

server <- function(input, output, session) {
	observe({
		qs <- session$clientData$url_search
		if (is.null(qs)) {
			qs <- ""
		}
		qs <- sub("^\\?", "", qs)
		query <- parseQueryString(qs)
		mode <- query[["mode"]]
		dark <- identical(mode, "dark")
		session$setCurrentTheme(make_theme(dark))
	})
}

shinyApp(ui, server)
