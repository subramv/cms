library('httr')
library('jsonlite')


query <- httr::GET("https://dnav.cms.gov/api/healthdata")
res <- jsonlite::fromJSON(rawToChar(query$content))
feesched <- lapply(res$dataset$keyword, function(ch) grep("Physician Fee Schedule", ch)) #find entries with desired keyword
feesched<- sapply(feesched, function(x) length(x) > 0) #keep only those that have the keyword
#which(feesched) #identifier 179 for national payment amount
with(res$dataset,distribution[identifier==179]) #print URLs to obtain database

#OR supply identifier directly 
query <- httr::GET("https://dnav.cms.gov/api/healthdata/179")
res <- jsonlite::fromJSON(rawToChar(query$content))

query <- httr::GET("https://www.cms.gov/apps/physician-fee-schedule/search/search-results.aspx?Y=0&T=0&HT=0&CT=3&H1=99203&M=5")
res <- jsonlite::fromJSON(rawToChar(query$content))

