library(rvest)
library(tidyverse)
library(assertthat)

localdb <- function(year,                    # last two digits of desired look-up year
                    locality,                # optional: valid 7-digit HCFS identification number; if not specified, will output full database
                    storage.path = NULL,     # directory in which storage folder exists or should be created (default: current working dir)
                    keep.downloads = T       # if T, downloaded files will not be deleted from storage folder, and will not need to be redownloaded for future operations.
                                             # if F, downloaded files will be removed once database is generated. storage folder will be deleted if empty
                    ){
  if(!missing(locality)) {
    assert_that(nchar(locality) == 7, msg = 'Locality code must be a valid 7-digit HCFS identification number')
    carrier.number <- substr(as.character(locality), 1, 5)
    localityid <- substr(as.character(locality), 6, 7)
    }
  assert_that(14<year & year<=20, msg = 'year must be a two digit integer between 14 and 20')
  storage.path = paste(storage.path, 'storage', sep = '')
  if(!dir.exists(storage.path)) dir.create(storage.path) # create storage folder if it does not exist
  assert_that(dir.exists(storage.path), msg = 'Storage folder not found or could not be created; check that provided storage path is valid and R has write permissions')
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
          full_join(anti_join(dblist[[2]], db1, by = 'HCPCS Code'), by = c("Year", "Carrier Number", "Locality", "HCPCS Code", "Modifier", "PCTC Indicator", "Status Code", 
                                                                           "Multiple Surgery Indicator", "50% Therapy Reduction Amount (non-institutional)", "50% Therapy Reduction Amount (institutional)", 
                                                                           "OPPS Indicator", "Facility Fee", "Non-Facility Fee", "OPPS Facility Fee", "OPPS Non-Facility Fee")) # addend non-overlapping rows
        return(res)
      } else{
        res<- dblist[[1]] %>% left_join(dblist[[2]], by = c('Year', 'Carrier Number', 'Locality', 'HCPCS Code', 'Modifier', 'Status Code', 'PCTC Indicator', 'Multiple Surgery Indicator', 
                                                '50% Therapy Reduction Amount (non-institutional)', '50% Therapy Reduction Amount (institutional)', 'OPPS Indicator')) %>%
          mutate('Facility Fee' = coalesce(`Facility Fee.y`, `Facility Fee.x`), 'Non-Facility Fee' = coalesce(`Non-Facility Fee.y`, `Non-Facility Fee.x`), 'OPPS Facility Fee' = 
                   coalesce(`OPPS Facility Fee.y`, `OPPS Facility Fee.x`), 'OPPS Non-Facility Fee' = coalesce(`OPPS Non-Facility Fee.y`, `OPPS Non-Facility Fee.x`)) %>%
          select(-`Facility Fee.x`, -`Facility Fee.y`, -`Non-Facility Fee.x`, -`Non-Facility Fee.y`, -`OPPS Facility Fee.x`, 
                 -`OPPS Facility Fee.y`, -`OPPS Non-Facility Fee.x`, -`OPPS Non-Facility Fee.y`) %>%
          full_join(anti_join(dblist[[2]], dblist[[1]], by = 'HCPCS Code'), by = c("Year", "Carrier Number", "Locality", "HCPCS Code", "Modifier", "PCTC Indicator", "Status Code", 
                                                                                   "Multiple Surgery Indicator", "50% Therapy Reduction Amount (non-institutional)", "50% Therapy Reduction Amount (institutional)", 
                                                                                   "OPPS Indicator", "Facility Fee", "Non-Facility Fee", "OPPS Facility Fee", "OPPS Non-Facility Fee")) # addend non-overlapping rows
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
  if (!keep.downloads){
    deletepaths <- vector(length = length(links), mode = 'character')
  }
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
    if(!keep.downloads){
      deletepaths[x] <<- path.zip  # save paths for later cleanup
    }
    return(outputdb)
  })
  if(!keep.downloads){
    unlink(deletepaths)
    if (length(list.files(storage.path)) == 0){
      unlink(storage.path, recursive = T)
    }
  }
  if(length(mpfs_all) == 1) {
    res<- mpfs_all[[1]] %>%  
      mutate(Modifier = forcats::as_factor(Modifier)) %>%
      mutate(Modifier = recode(Modifier, "  " = "none"))
  } else{
    res <- joinall(mpfs_all) %>%  
      mutate(Modifier = forcats::as_factor(Modifier)) %>%
      mutate(Modifier = recode(Modifier, "  " = "none"))
  }
  if(!missing(locality)){
    assert_that(carrier.number %in% res$`Carrier Number`, msg = 'Provided locality does not match entries in this database')
    assert_that(localityid %in% res$Locality, msg = 'Provided locality does not match entries in this database')
    res <- res %>% 
      filter(`Carrier Number` == carrier.number) %>%
      filter(`Locality` == localityid)
  }
  return(res)
}

  


  
