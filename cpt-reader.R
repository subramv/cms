library('tidyverse')

mpfs_rev<- readr::read_delim("PFREV20B.txt", delim=',', col_names = c("Year", "Carrier Number", "Locality", "HCPCS Code", "Modifier", "Non-Facility Fee", 
                                                                    "Facility Fee", "Filler", "PCTC Indicator", "Status Code", "Multiple Surgery Indicator", 
                                                                    "50% Therapy Reduction Amount (non-institutional)", "50% Therapy Reduction Amount (institutional)", 
                                                                    "OPPS Indicator", "OPPS Non-Facility Fee", "OPPS Facility Fee")) %>%
  select(-8) # remove filler column 
mpfs_rev<- slice(mpfs_rev,-((nrow(mpfs_rev)-3):nrow(mpfs_rev))) # remove copyright rows

mpfs_nat<- readr::read_delim("PFALL20.txt", delim=',', col_names = c("Year", "Carrier Number", "Locality", "HCPCS Code", "Modifier", "Non-Facility Fee", 
                                                                     "Facility Fee", "Filler", "PCTC Indicator", "Status Code", "Multiple Surgery Indicator", 
                                                                     "50% Therapy Reduction Amount (non-institutional)", "50% Therapy Reduction Amount (institutional)", 
                                                                     "OPPS Indicator", "OPPS Non-Facility Fee", "OPPS Facility Fee")) %>%
  select(-8) # remove filler column 
mpfs_nat<- slice(mpfs_nat,-((nrow(mpfs_nat)-3):nrow(mpfs_nat))) #%>% # remove copyright rows


  
