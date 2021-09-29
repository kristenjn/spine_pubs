#-----------------------
#
#	SCOPUS
#
#-----------------------


scopus_base <- "https://api.elsevier.com/content/search/scopus"
scopus_query <- config::get("scopus_query")
scopus_date <- substr(search_from, start = 1, stop = 4)
#can do ranges i.e. 2014-2017, but can't specify lower than a year
scopus_url <- paste0(scopus_base,
                     "?query=", scopus_query,
                     "&date=",scopus_date, 
                     "&apiKey=", api_key)
scopus_url <- URLencode(scopus_url)
docs <- GET(scopus_url)
json_docs <- httr::content(docs)
json_docs2 <- jsonlite::fromJSON(toJSON(json_docs), flatten = TRUE)
(total <- as.numeric(json_docs2[["search-results"]][["opensearch:totalResults"]]))
(perpage <- as.numeric(json_docs2[["search-results"]][["opensearch:itemsPerPage"]]))


#-----------------------
#
#	GET ALL SCOPUS RECORDS
#
#-----------------------


pages <- list()
for (i in 1:ceiling(total/perpage)) {
  scopus_url <- paste0(scopus_base,
                       "?query=", scopus_query,
                       "&date=",scopus_date, 
                       "&start=", (i-1)*25,
                       "&apiKey=", config::get("scopus_api"))
  scopus_url <- URLencode(scopus_url)
  docs <- GET(scopus_url)
  json_docs <- httr::content(docs)
  json_docs2 <- jsonlite::fromJSON(toJSON(json_docs), flatten = TRUE)
  
  pages[[i]] <- json_docs2[["search-results"]][["entry"]]
}

#-----------------------
#
#	CONVERT SCOPUS JSON FILE TO DATAFRAME
#
#-----------------------


#names <- c("dc:title", "dc:creator", "prism:publicationName", "prism:coverDate", "prism:doi", "affiliation", "subtypeDescription")
names <- names(pages[[1]])
df.scopus <- setNames(data.frame(matrix(ncol = length(names), nrow = 0)), c(names))

for (i in 1:length(pages)){
  temp <- pages[[i]]
  
  if (length(temp) > 0) {
    common.names <- intersect(names, colnames(temp))
    scopus <- temp[, common.names]
    for (j in 1:length(scopus)) {
      scopus[,j] <- sapply(scopus[,j], 
                           function(x)  ifelse(!is.null(dim(x)), paste(unlist(x), collapse=", "),
                                               ifelse(length(x)==0, "NA", x)))
    }
    
    scopus <- as.data.frame(scopus, stringsAsFactors=FALSE)		
    
    df.scopus <- rbind.fill(df.scopus, scopus)
  }
}
copy.table(df.scopus)
write.csv(df.scopus, paste(save_path, "scopus_", Sys.Date(),".csv", sep = ""), row.names=FALSE)