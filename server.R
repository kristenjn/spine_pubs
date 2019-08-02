library(shinyjs)

source("./www/pubmed_api.R")

server <- function(input, output, session) {
  
  #Observers----
  observeEvent(input$select_journal, {
    shinyjs::runjs("window.scrollTo(0, 0)")
  })
  
  #UI elements----
  output$journal <- renderUI({input$select_journal})
  
  output$pubmed <- renderUI({
    # results = pubmed_by_journal(n.days = 45, search.term = "Global Spine J", limit=10)
    if (input$select_journal == "Global Spine J") {
      database = "pubmed"
    } else {
      database = "pubmed"
    }
    results = pubmed_by_journal(n.days = 120, 
                                search.term = input$select_journal,
                                db = database,
                                limit=50)
    if (is.null(results)) {
      return("No results for selected journal")
    } else {
      if (database == "pubmed") {
        df_articles = pubmed_to_df(results)
        df_articles$date = as.POSIXct(paste0('01', df_articles$date), format="%d %b %Y")
        df_articles = df_articles[rev(order(df_articles$date)),]
        df_articles$date = format(df_articles$date, "%b %Y")
      } else {
        df_articles = pmc_to_df(results)
        df_articles$date = as.POSIXct(paste0('01', df_articles$date), format="%d %m %Y")
        df_articles = df_articles[rev(order(df_articles$date)),]
        df_articles$date = format(df_articles$date, "%b %Y")
      }
      article_list = pubmedf_to_list(df_articles)
      return(HTML(paste(article_list, collapse = "<hr>")))
    }
    })
  
} #end server
