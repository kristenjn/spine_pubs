#Entrez Unique Identifiers (UIDs) for selected databases
# Entrez Database - PubMed	
# UID common name - PMID
# E-utility Database Name - pubmed


require(httr)
require(plyr)
require(XML)



pubmed_by_journal <- function(n.days = 30,
                              search.term,
                              db = "pubmed",
                              limit = 20,
                              api_key) {

  #serach parameters----
  
  date.type <- "pdat" #use publication date
  search.field <- "ta" #use abbreviated title field
  base_url <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/"

  #use eSearch to retrieve list of ID's----
  url = paste0(base_url, 
               "esearch.fcgi?db=", db, 
               "&term=\"", search.term, "\"",
               "&field=", search.field,
               "&usehistory=y",
               "&retmax=", limit,
               "&datetype=", date.type,
               "&reldate=", n.days,
               "&api_key=", api_key)
  
  url = URLencode(url)
  pubs = httr::GET(url)
  xml.pubs = xmlParse(pubs)
  df.pubs = ldply(xmlToList(xml.pubs), data.frame)
  id.cols = grep("^Id", colnames(df.pubs))
  id.row = grep("IdList", df.pubs[,1])
  id.list = t(df.pubs[id.row, id.cols])
  n.records = length(id.list)
  # print(paste0("number of records returned: ", n.records))
  if (n.records == 0) {
    results = NULL
  } else {
    #split list of ID's into groups of 20----
    id.query <- NA
    if (n.records <= 20){
      id.query <- paste(id.list, collapse=",")
    }else {
      for (i in 1:ceiling(n.records/20)) {
        min = 20*i-19
        max = 20*i
        id.temp <- id.list[min:max]
        id.query[i] <- paste(id.temp, collapse=",")
      }
    }
    
    #use eFetch to get article information from list of ID's----
    results <- list()
    for (k in 1:length(id.query)){
      id.search <- id.query[k]
      url <- paste0(base_url, "efetch.fcgi?db=", db, 
                    "&rettype=xml&id=", id.search,
                    "&api_key=", api_key)
      url <- URLencode(url)
      docs <- GET(url)
      docs
      xml.docs <- xmlParse(docs)
      results[[k]] <- xmlRoot(xml.docs)
    }
  }
  return(results)
}

pubmed_to_df <- function(results) {
  names = c( "title", "title", "abstract", "auth", "date", "dois")
  df.pubmed = setNames(data.frame(matrix(ncol = length(names), nrow = 0)), c(names))
  
  for (k in 1:length(results)) {
    temp.results = results[[k]] #get first page
    
    for (i in 1:xmlSize(temp.results)){
      df.temp = setNames(data.frame(matrix(ncol = length(names), nrow = 1)), c(names))
      doc = temp.results[[i]][['MedlineCitation']][['Article']]
      
      df.temp$title = xmlValue(doc[['ArticleTitle']])
      df.temp$journal = xmlValue(doc[['Journal']][['ISOAbbreviation']])
      df.temp$abstract = xmlValue(doc[['Abstract']])
      df.temp$date = paste(xmlValue(doc[['Journal']][['JournalIssue']][['PubDate']][['Month']]),
                           xmlValue(doc[['Journal']][['JournalIssue']][['PubDate']][['Year']]),
                           sep=" ")
      # print(doc)
      df.temp$dois = ifelse(length(xpathSApply(doc, "ELocationID[@EIdType='doi']", xmlValue))==0,
                            NA,
                            paste0("http://dx.doi.org/",
                                   xpathSApply(doc, "ELocationID[@EIdType='doi']", xmlValue))
      )
      auth.list = NA
      auth.list = doc[['AuthorList']]
      for (j in 1:xmlSize(auth.list)){
        temp = auth.list[[j]]
        last = xmlValue(temp[['LastName']])
        first = xmlValue(temp[['Initials']])
        name = paste(last, first, sep=" ")
        if (j==1){
          df.temp$auth = name
        }else if (j>1){
          df.temp$auth = paste(df.temp$auth, name, sep=", ")
        }
      }
      df.pubmed = rbind.fill(df.pubmed, df.temp)
    }
  }
  return(df.pubmed)
}

pmc_to_df <- function(results){
  names = c( "title", "title", "abstract", "auth", "date", "dois")
  df_pmc = setNames(data.frame(matrix(ncol = length(names), nrow = 0)), c(names))
  
  for (k in 1:length(results)) {
    temp.results = results[[k]] #get first page
    
    for (i in 1:xmlSize(temp.results)){
      df.temp = setNames(data.frame(matrix(ncol = length(names), nrow = 1)), c(names))
      doc = temp.results[[i]][["front"]]
      
      df.temp$title = xmlValue(doc[["article-meta"]][["title-group"]][["article-title"]])
      df.temp$journal = xmlValue(doc[["journal-meta"]][["journal-title-group"]][["journal-title"]])
      df.temp$abstract = "Not Available"
      
      df.temp$date = paste(xmlValue(doc[["article-meta"]][["pub-date"]][["month"]]),
                           xmlValue(doc[["article-meta"]][["pub-date"]][["year"]]),
                           sep=" ")
      df.temp$dois = ifelse(length(xpathSApply(doc[['article-meta']], "article-id[@pub-id-type='doi']", xmlValue))==0,
                            NA,
                            paste0("http://dx.doi.org/",
                                   xpathSApply(doc[['article-meta']], "article-id[@pub-id-type='doi']", xmlValue))
      )
      auth.list = NA
      auth.list = doc[["article-meta"]][["contrib-group"]]
      for (j in 1:xmlSize(auth.list)){
        temp = auth.list[[j]]
        last = xmlValue(temp[["name"]][["surname"]])
        first = xmlValue(temp[["name"]][["given-names"]])
        name = paste(last, first, sep=" ")
        if (j==1){
          df.temp$auth = name
        }else if (j>1){
          df.temp$auth = paste(df.temp$auth, name, sep=", ")
        }
      }
      df_pmc = rbind.fill(df_pmc, df.temp)
    }
  }
  return(df_pmc)
}

pubmedf_to_list <- function(df.pubmed) {
  list.pubmed = list()
  for (i in 1:dim(df.pubmed)[1]) {
    elem = df.pubmed[i,]
    list.pubmed[[i]] = paste0(
      "<b style='font-size:2rem;'>", elem$title, "</b><br>",
      elem$auth,
      "<br>",
      elem$journal,
      "<br>",
      "Publication date: ", elem$date,
      "<br>",
      "<a href=", elem$dois, " target='_blank'>", elem$dois,"</a>",
      "<br><br>",
      elem$abstract,
      "<br>"
    )
  }
  return(list.pubmed)
}