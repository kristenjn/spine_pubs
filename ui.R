library(shiny)
library(DT)
library(shinydashboard)
library(shinyWidgets)
library(shinyjs)

ui <- dashboardPage(skin = "black",
                    
                    dashboardHeader(titleWidth = 200,
                                    title = "Spine Pubs"
                                    ),
                    #sidebar ----
                     dashboardSidebar(
                      width = 200,
                      sidebarMenu(id = "tabs",
                        menuItem("PubMed", tabName = "pubmed", icon = icon("searchengin")),
                        menuItem("Apps", tabName = "apps", icon = icon("calculator")),
                        hr(style = "border-color:#fff;margin-left:10px;"),
                        div(
                            shinyWidgets::radioGroupButtons(inputId = "select_journal",
                                                            label = NULL,
                                                            width = NULL,
                                                            choices = c("Bone Joint J",
                                                                        "Clin Orthop Relat Res",
                                                                        "Clin Spine Surg",
                                                                        "Eur Spine J",
                                                                        "Global Spine J",
                                                                        "J Am Acad Orthop Surg",
                                                                        "J Bone Joint Surg Am",
                                                                        "J Neurosurg",
                                                                        "J Neurosurg Spine",
                                                                        "J Neurotrauma",
                                                                        "J Orthop Res",
                                                                        "J Orthop Surg Res",
                                                                        "J Orthop Trauma",
                                                                        "JBJS Rev",
                                                                        "Neurosurgery",
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
                      tabItems(
                        tabItem(tabName = "pubmed",
                                div(style = "display:block;overflow:auto;",
                                    column(width = 12,
                                           fluidRow(
                                             style = "padding-left: 5px; padding-right: 5px; text-align: justify; font-size: 1.3rem;",
                                             shiny::uiOutput("pubmed")
                                           ) #end fluidRow
                                    ) #end column
                                ) #end div
                        ), #end pubmed tabName
                        tabItem(tabName = "apps",
                                column(width = 12,
                                       fluidRow(
                                         shiny::uiOutput("apps")
                                       ) #end fluidrow
                                ) #end column
                        ) #end apps tabName
                      ) #end tabItems
                    ) #end dashboardBody
) #end ui