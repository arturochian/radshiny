# some common sense packages to add to global.R
.additionalPackages <- c('htmlwidgets', 'ggplot2', 'dplyr')

.serverString <- '
shinyServer(function(input, output, session) {

  observe({

    ## prints page name to console.
    cat(paste0("Page: ", input$page, "\n"))
    output$char <- renderText(paste0("page: ", input$page))


  }, label="pageObserver")

  observe({
%s
  })
})
'

.observeString <- "
\t\tif(input$page == '%s'){
\t\t\tfor(f in list.files('%s', pattern = '*.(R|r)$', full.names = TRUE))
\t\t\t\tsource(f, local=TRUE)
\t\t}
"

.uiString <- "
shinyUI(
  fluidPage(
    tags$head(tags$link(rel='stylesheet', type='text/css', href='style.css')),
    nav(menus, id='page', brand='%s'),
    titlePanel('Title Panel'),
    sidebarLayout(
      sidebarPanel(width=3,
        textOutput('char')
      ),
      mainPanel(
        tabs(menus, id='tabs', brand='%s')
      )
    )
  )
)
"
