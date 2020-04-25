library('httr')
library('jsonlite')


res <- httr::GET("https://dnav.cms.gov/api/healthdata")
data <- jsonlite::fromJSON(rawToChar(res$content))
feesched <- lapply(data$dataset$keyword, function(ch) grep("Physician Fee Schedule", ch)) #find entries with desired keyword
feesched<- sapply(feesched, function(x) length(x) > 0) #keep only those that have the keyword
#which(feesched) #identifier 179 for national payment amount
with(data$dataset,distribution[identifier==179]) #print URLs to obtain database

