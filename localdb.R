library(rvest)
library(tidyverse)
library(assertthat)

localdb <- function(year,                    # last two digits of desired look-up year
                    locality = NULL,         # valid locality code; if not specified, will output full database
                    storage.path = NULL,     # directory in which storage folder exists or should be created (default: current working dir)
                    keep.downloads = T       # if T, downloaded files will not be deleted from storage folder, and will not have to be redownloaded
                    #output filename, output storage path (default: current working dir)
                    ){
  assert_that(14<year & year<=20, msg = 'year must be a two digit integer between 14 and 20')
  storage.path = paste(storage.path, 'storage', sep = '')
  if(!dir.exists(storage.path)) dir.create(storage.path) # create storage folder if it does not exist
  assert_that(dir.exists(storage_path), msg = 'Storage folder not found or could not be created; check that provided storage path is valid and R has write permissions')
  # define joining function
  joinall <- function(inputlist){
    recursivejoin <- function(dblist, index){
      if (index >2){
        db1 <- Recall(dblist, index-1)
        res<- db1 %>% left_join(dblist[[2]], by = c('Year', 'Carrier Number', 'Locality', 'HCPCS Code', 'Modifier', 'Status Code', 'PCTC Indicator', 'Multiple Surgery Indicator', 
                                                            '50% Therapy Reduction Amount (non-institutional)', '50% Therapy Reduction Amount (institutional)', 'OPPS Indicator')) %>%
          mutate('Facility Fee' = coalesce(`Facility Fee.y`, `Facility Fee.x`), 'Non-Facility Fee' = coalesce(`Non-Facility Fee.y`, `Non-Facility Fee.x`), 'OPPS Facility Fee' = 
                   coalesce(`OPPS Facility Fee.y`, `OPPS Facility Fee.x`), 'OPPS Non-Facility Fee' = coalesce(`OPPS Non-Facility Fee.y`, `OPPS Non-Facility Fee.x`)) %>%
          select(-`Facility Fee.x`, -`Facility Fee.y`, -`Non-Facility Fee.x`, -`Non-Facility Fee.y`, -`OPPS Facility Fee.x`, 
                 -`OPPS Facility Fee.y`, -`OPPS Non-Facility Fee.x`, -`OPPS Non-Facility Fee.y`) %>%
          full_join(anti_join(dblist[[2]], db1, by = 'HCPCS Code')) # addend non-overlapping rows
        return(res)
      } else{
        res<- dblist[[1]] %>% left_join(dblist[[2]], by = c('Year', 'Carrier Number', 'Locality', 'HCPCS Code', 'Modifier', 'Status Code', 'PCTC Indicator', 'Multiple Surgery Indicator', 
                                                '50% Therapy Reduction Amount (non-institutional)', '50% Therapy Reduction Amount (institutional)', 'OPPS Indicator')) %>%
          mutate('Facility Fee' = coalesce(`Facility Fee.y`, `Facility Fee.x`), 'Non-Facility Fee' = coalesce(`Non-Facility Fee.y`, `Non-Facility Fee.x`), 'OPPS Facility Fee' = 
                   coalesce(`OPPS Facility Fee.y`, `OPPS Facility Fee.x`), 'OPPS Non-Facility Fee' = coalesce(`OPPS Non-Facility Fee.y`, `OPPS Non-Facility Fee.x`)) %>%
          select(-`Facility Fee.x`, -`Facility Fee.y`, -`Non-Facility Fee.x`, -`Non-Facility Fee.y`, -`OPPS Facility Fee.x`, 
                 -`OPPS Facility Fee.y`, -`OPPS Non-Facility Fee.x`, -`OPPS Non-Facility Fee.y`) %>%
          full_join(anti_join(dblist[[2]], dblist[[1]], by = 'HCPCS Code')) # addend non-overlapping rows
        return(res)
      }
    }
    recursivejoin(inputlist, length(inputlist))
    }
  # --------------------------------------------
  
  landingurl <- "https://www.cms.gov/Medicare/Medicare-Fee-for-Service-Payment/PhysicianFeeSched/PFS-National-Payment-Amount-File?items_per_page=100&combine="
  baseurl <- "https://www.cms.gov"
  links<- read_html(landingurl) %>% html_nodes("a") %>% html_attr("href") 
  links <- links[grepl(paste('pf.{3,}', year,'[abcd]',sep=''), links, ignore.case=T)]
  links <- links[order(links, substr(links, nchar(links), nchar(links)))] # order alphabetically
  mpfs_all<-map(1:length(links), function(x){
    siteurl <- paste(baseurl, links[x], sep='')
    dblink <- read_html(siteurl) %>% html_nodes("a") %>% html_attr("href") %>% str_subset("\\.zip")
    dblink <- paste(baseurl, dblink, sep = '')
    path.zip <- paste(storage.path, sub(".*/", "", dblink), sep = '/')
    if(!file.exists(path.zip)) download.file(dblink, path.zip)
    zipped.txt.name <- grep('\\.txt$', unzip(path.zip, list=TRUE)$Name, 
                             ignore.case=TRUE, value=TRUE)
    unzip(path.zip, exdir = storage.path, files = zipped.txt.name)
    outputdb <- suppressMessages(suppressWarnings(readr::read_delim(paste(storage.path, zipped.txt.name, sep = '/'), delim = ',', 
                                              col_names = c("Year", "Carrier Number", "Locality", "HCPCS Code", "Modifier", "Non-Facility Fee", 
                                                      "Facility Fee", "Filler", "PCTC Indicator", "Status Code", "Multiple Surgery Indicator", 
                                                      "50% Therapy Reduction Amount (non-institutional)", "50% Therapy Reduction Amount (institutional)", 
                                                      "OPPS Indicator", "OPPS Non-Facility Fee", "OPPS Facility Fee")) %>%
      select(-8) # remove filler column
    ))
    outputdb <- outputdb %>%  slice(-((nrow(outputdb)-3):nrow(outputdb)))
    unlink (paste(storage.path, zipped.txt.name, sep = '/')) # delete unzipped .txt
    return(outputdb)
  })
  if(length(mpfs_all) == 1) {
    return(mpfs_all[[1]])
  } else{
    res <- joinall(mpfs_all) %>%  
      mutate(Modifier = forcats::as_factor(Modifier)) %>%
      mutate(Modifier = recode(Modifier, "  " = "none"))
    return(res)
  }
}
  
  
  
