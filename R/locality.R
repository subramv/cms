#DEPENDENCIES: readr, tidyr, %>%

# function that returns PFS locality dictionary for 2020
get_locality_key <- function(){ 
  rawdat <- readr::read_tsv('data-raw/18LOCCO.txt', skip = 2, 
                            col_names = c('Carrier Number', 'Locality',
                                          'State', 'Fee Schedule Area',
                                          'Counties', 'Filler'),
                            col_types = readr::cols(
                              'Carrier Number' = readr::col_character(),
                              'Locality' = readr::col_character(),
                              'State' = readr::col_character(),
                              'Fee Schedule Area' = readr::col_character(),
                              'Counties' = readr::col_character(),
                              'Filler' = readr::col_skip())) %>%
    tidyr::drop_na(1) %>%
    dplyr::select(1:5) %>%
    tidyr::fill('State', .direction = 'down')
  rawdat$`Carrier Number`[rawdat$`Carrier Number` %in% c('10102', '10202', '10302')] <- 
    c('10112', '10212', '10212', '10312')
  return(rawdat)
}


