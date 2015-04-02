library(shiny)

menu = tagList(
  navbarMenu('Page1',
  	tabPanel('Sub1', id = 'page1_sub1'),
  	tabPanel('Sub2', id = 'page1_sub2')
  ),
  tabPanel('Page2', id = 'page2'),
  tabPanel('Page3', id = 'page3'),
  navbarMenu('Page4',
  	navbarMenu('Sub1',
  		tabPanel('Sub2', id = 'page4_sub1_sub2')
  ),
  	tabPanel('Sub2', id = 'page4_sub2')
  )
)



shinyUI(
  fluidPage(
    tags$head(tags$link(rel='stylesheet', type='text/css', href='style.css')),
    nav(menus, id='page', brand='page1'),
    titlePanel('Title Panel'),
    sidebarLayout(
      sidebarPanel(width=3,
        textOutput('char')
      ),
      mainPanel(
        tabs(menus, id='tabs', brand='page1')
      )
    )
  )
)

