library(tidyverse)

localitydict <- function(filepath){ #path to CMS locality configuration text file
  readr::read_tsv(filepath, skip = 2, col_names = T) %>%
    tidyr::drop_na(1) %>%
    dplyr::select(1:5) %>%
    tidyr::fill('State', .direction = 'down')
  
}

popdb <- readr::read_csv('co-est2019-alldata.csv')
locald<-localitydict('storage/18LOCCO.txt') %>%
  slice(-which(is.na(.$Counties))) # remove duplicate Wyoming
stateindex <-grep('All ', locald$Counties, ignore.case = T)
counties <- locald %>% dplyr::slice(-stateindex,)
countiespop <- sapply(1:nrow(counties), function(x){
  indiv <- trimws(unlist(strsplit(counties[[x,5]], ' AND')))
  indiv <- trimws(unlist(strsplit(indiv, ',')))
  sum(sapply(seq_along(indiv), function(y){
    popdb %>% filter(tolower(STNAME) == tolower(counties[[x,3]]), grepl(paste(indiv[y], '', sep = ' '),popdb$CTYNAME, ignore.case = T)) %>%
    pull(8) %>% sum
  }))
}) 

#%>% mutate(counties, Population = .) %>%
  #left_join(locald, ., by = c('Carrier Number', 'Locality Number', 'State', 'Fee Schedule Area', 'Counties'))
other <- locald %>% dplyr::slice(stateindex,)
otherpop<-sapply(1:nrow(other), function(x){
    popdb %>% filter(grepl(other$State[[x]],popdb$CTYNAME, ignore.case = T)) %>%
      pull(8) %>% sum
})
pops <- vector(mode = 'numeric', length = nrow(locald))
pops[-stateindex] = countiespop
pops[stateindex] = otherpop
pops[pops==0] = 1
locald<- locald %>% mutate('2010 Census' = pops) %>% unique
otherindex<-grep('All Other', locald$Counties, ignore.case = T)
for(x in seq_along(otherindex)){  
  state<-locald$State[otherindex[x]]
  othersum<- locald%>% filter(State == state) %>%
    slice(-nrow(.)) %>% select(6) %>% sum
  locald[otherindex[x],6] <-locald[otherindex[x],6] - othersum  
}
locald$`Carrier Number`[locald$`Carrier Number` %in% c('10102', '10202', '10302')] <- c('10112', '10212', '10212', '10312')

readr::write_csv(locald, 'localitypopulations.csv')
