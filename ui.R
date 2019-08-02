library(shiny)
library(DT)
library(shinydashboard)
library(shinyWidgets)
library(shinyjs)

ui <- dashboardPage(skin = "black",
                    
                    dashboardHeader(titleWidth = 150,
                                    title = "Spine Pubs"
                                    ),
                    #sidebar ----
                     dashboardSidebar(
                      width = 150,
                      sidebarMenu(
                        div(
                            shinyWidgets::radioGroupButtons(inputId = "select_journal",
                                                            label = NULL,
                                                            width = NULL,
                                                            choices = c("Clin Spine Surg",
                                                                        "Eur Spine J",
                                                                        "Global Spine J",
                                                                        "J Neurosurg",
                                                                        "J Neurosurg Spine",
                                                                        "Spine",
                                                                        "Spine J"
                                                                        ),
                                                            direction = "vertical"
                                                            ) #end radiogroup
                            ) #end div
                      )
                     ), #end sidebar
                    #body----
                    dashboardBody(
                      useShinyjs(),
                      tags$head(tags$link(rel = "stylesheet", 
                                          type = "text/css", 
                                          href = "bootswatch_spine.css"
                                          )
                      ),
                      div(style = "display:block;overflow:auto;margin-top:75px;",
                          column(width = 12,
                                 fluidRow(
                                   style = "padding-left: 5px; padding-right: 5px; text-align: justify;",
                                   shiny::uiOutput("pubmed")
                                 ) #end fluidRow
                          ) #end column
                      ) #end div
                    ) #end dashboardBody
) #end ui