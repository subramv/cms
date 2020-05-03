library(rvest)
library(tidyverse)

localdb <- function(year,                    # last two digits of desired look-up year
                    locality = NULL          # valid locality code; if not specified, will output full database
                    ){
  landingurl <- "https://www.cms.gov/Medicare/Medicare-Fee-for-Service-Payment/PhysicianFeeSched/PFS-National-Payment-Amount-File?items_per_page=100&combine="
  baseurl <- "https://www.cms.gov"
  links<- read_html(landingurl) %>% html_nodes("a") %>% html_attr("href") 
  links <- links[grepl(paste('pf.{3,}', year,'[abcd]',sep=''), links, ignore.case=T)]
  mpfs_all<-map(1:length(links), function(x){
    siteurl <- paste(baseurl, links[x], sep='')
    dblink <- read_html(siteurl) %>% html_nodes("a") %>% html_attr("href")
    #dblink <- dblink[grepl]  
  })
  
  
  mpfs_rev <- readr::read_delim("PFREV20B.txt", delim=',', col_names = c("Year", "Carrier Number", "Locality", "HCPCS Code", "Modifier", "Non-Facility Fee", 
                                                                         "Facility Fee", "Filler", "PCTC Indicator", "Status Code", "Multiple Surgery Indicator", 
                                                                         "50% Therapy Reduction Amount (non-institutional)", "50% Therapy Reduction Amount (institutional)", 
                                                                         "OPPS Indicator", "OPPS Non-Facility Fee", "OPPS Facility Fee")) %>%
    select(-8) # remove filler column 
  mpfs_rev <- mpfs_rev %>% slice(-((nrow(mpfs_rev)-3):nrow(mpfs_rev))) # remove copyright rows
  
  
  mpfs_nat <- readr::read_delim("PFALL20.txt", delim=',', col_names = c("Year", "Carrier Number", "Locality", "HCPCS Code", "Modifier", "Non-Facility Fee", 
                                                                        "Facility Fee", "Filler", "PCTC Indicator", "Status Code", "Multiple Surgery Indicator", 
                                                                        "50% Therapy Reduction Amount (non-institutional)", "50% Therapy Reduction Amount (institutional)", 
                                                                        "OPPS Indicator", "OPPS Non-Facility Fee", "OPPS Facility Fee")) %>%
    select(-8) # remove filler column 
  mpfs_nat <- mpfs_nat %>% slice(-((nrow(mpfs_nat)-3):nrow(mpfs_nat))) # remove copyright rows
  
  res <- mpfs_nat %>% left_join(mpfs_rev, by = c('Year', 'Carrier Number', 'Locality', 'HCPCS Code', 'Modifier', 'Status Code', 'PCTC Indicator', 'Multiple Surgery Indicator', 
                                                 '50% Therapy Reduction Amount (non-institutional)', '50% Therapy Reduction Amount (institutional)', 'OPPS Indicator')) %>%
    mutate('Facility Fee' = coalesce(`Facility Fee.y`, `Facility Fee.x`), 'Non-Facility Fee' = coalesce(`Non-Facility Fee.y`, `Non-Facility Fee.x`), 'OPPS Facility Fee' = 
             coalesce(`OPPS Facility Fee.y`, `OPPS Facility Fee.x`), 'OPPS Non-Facility Fee' = coalesce(`OPPS Non-Facility Fee.y`, `OPPS Non-Facility Fee.x`)) %>%
    select(-`Facility Fee.x`, -`Facility Fee.y`, -`Non-Facility Fee.x`, -`Non-Facility Fee.y`, -`OPPS Facility Fee.x`, 
           -`OPPS Facility Fee.y`, -`OPPS Non-Facility Fee.x`, -`OPPS Non-Facility Fee.y`) %>%
    full_join(anti_join(mpfs_rev, mpfs_nat, by = 'HCPCS Code')) %>% # addend non-overlapping rows
    mutate(Modifier = forcats::as_factor(Modifier)) %>%
    mutate(Modifier = recode(res$Modifier, "  " = "none"))
}