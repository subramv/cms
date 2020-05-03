library('httr')
library('jsonlite')

# function that returns identifiers of databases on dnav.cms.gov that match a specific search string
dbID <- function(searchterm){          # desired keyword
  query <- httr::GET("https://dnav.cms.gov/api/healthdata")
  res <- jsonlite::fromJSON(rawToChar(query$content))
  matches <- lapply(res$dataset$keyword, function(ch) grep(searchterm, ch)) #find entries with desired keyword
  matches<- sapply(matches, function(x) length(x) > 0) #keep only those that have the keyword
  which(matches) 
}


