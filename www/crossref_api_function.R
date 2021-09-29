#-----------------------
#
#	CROSSREF
#
#-----------------------

cross_base <- "https://api.crossref.org/works"
cross_query <- config::get("cross_query")
cross_contact <- config::get("cross_contact")

cross_url <- paste0(cross_base, 
                    cross_query,
                    "&filter=from-pub-date:",search_from, 
                    "&rows=1",
                    cross_contact)

cross_url <- URLencode(cross_url)
docs <- httr::GET(cross_url)
json_docs <- httr::content(docs)
(total <- json_docs[["message"]][["total-results"]])

#-----------------------
#
#	GET ALL RECORDS BY PAGING THROUGH VIA CURSOR
#
#-----------------------

pages <- list()
i <- 0
cursor_i <- "*"
while (!length((json_docs[["message"]][["items"]]))==0) {
  print(i <- i+1)
  cross_url <- paste0(cross_base, 
                      cross_query,
                      "&sort=published&order=desc",
                      "&filter=from-pub-date:",search_from, 	#include this line if filtering by "from_date
                      "&rows=100",
                      cross_contact,
                      "&cursor=",
                      cursor_i)
  cross_url <- URLencode(cross_url)
  docs <- httr::GET(cross_url)
  json_docs <- httr::content(docs)
  print(cursor_i <- json_docs[["message"]][["next-cursor"]])
  (cursor_i <- URLencode(cursor_i, reserved=T))
  !length((json_docs[["message"]][["items"]]))==0
  json_docs2 <- jsonlite::fromJSON(toJSON(json_docs), flatten = TRUE)
  pages[[i]] <- json_docs2$message$items
}



#-----------------------
#
#	CONVERT CROSSREF JSON FILE TO DATAFRAME
#
#-----------------------


names <- names(pages[[1]])

df.crossref <- setNames(data.frame(matrix(ncol = length(names), nrow = 0)), c(names))	

for (i in 1:length(pages)){
  print(i)
  temp <- pages[[i]]
  
  if (length(temp) > 0) {
    common.names <- intersect(names, colnames(temp))
    crossref <- temp[, common.names]
    auth <- crossref$author
    auth <- lapply(auth, function(x) paste(paste0(x[[2]], " ", substr(x[[1]], 1, 1)), collapse=", "))
    crossref$author <- auth
    for (j in 1:length(crossref)) {
      crossref[,j] <- sapply(crossref[,j], 
                             function(x)  ifelse(!is.null(dim(x)), paste(unlist(x), collapse=", "),
                                                 ifelse(length(x)==0, "NA",
                                                        ifelse(is.list(x) & is.na(unlist(x)), "NA", x))))
    }
    
    crossref <- as.data.frame(crossref, stringsAsFactors=FALSE)		
    
    df.crossref <- rbind.fill(df.crossref, crossref)
  }
}

copy.table(df.crossref)
write.csv(df.crossref, paste(save_path, "crossref_", Sys.Date(),".csv", sep = ""), row.names=FALSE)