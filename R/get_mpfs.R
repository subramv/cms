#DEPENDENCIES: rvest, xml2 (dependency of rvest), dplyr, readr

download_mpfs <- function(year, storage_path, keep_downloads){
  landingurl <- "https://www.cms.gov/Medicare/Medicare-Fee-for-Service-Payment/PhysicianFeeSched/PFS-National-Payment-Amount-File?items_per_page=100&combine="
  baseurl <- "https://www.cms.gov"
  links <- xml2::read_html(landingurl)
  links <- rvest::html_nodes(links, "a")
  links <- rvest::html_attr(links, "href") 
  links <- links[grepl(paste('pf.{3,}', year,'[abcd]',sep=''), links, ignore.case=T)]
  links <- links[order(links, substr(links, nchar(links), nchar(links)))] # order alphabetically
  if (!keep_downloads){
    deletepaths <- vector(length = length(links), mode = 'character')
  }
  mpfs_all<-lapply(1:length(links), function(x){
    siteurl <- paste(baseurl, links[x], sep='')
    dblink <- xml2::read_html(siteurl)
    dblink <- rvest::html_nodes(dblink, "a")
    dblink <- rvest::html_attr(dblink, "href")
    dblink <- grep("\\.zip", dblink, value = T)
    dblink <- paste(baseurl, dblink, sep = '')
    path.zip <- paste(storage_path, sub(".*/", "", dblink), sep = '/')
    if(!file.exists(path.zip)) utils::download.file(dblink, path.zip)
    zipped.txt.name <- grep('\\.txt$', utils::unzip(path.zip, list=TRUE)$Name, 
                            ignore.case=TRUE, value=TRUE)
    utils::unzip(path.zip, exdir = storage_path, files = zipped.txt.name)
    outputdb <- suppressMessages(suppressWarnings(readr::read_delim(paste(storage_path, zipped.txt.name, sep = '/'), delim = ',', progress = F, 
                                                                    col_names = c("Year", "Carrier Number", "Locality", "HCPCS Code", "Modifier", "Non-Facility Fee", 
                                                                                  "Facility Fee", 'Filler', "PCTC Indicator", "Status Code", "Multiple Surgery Indicator", 
                                                                                  "50% Therapy Reduction Amount (non-institutional)", "50% Therapy Reduction Amount (institutional)", 
                                                                                  "OPPS Indicator", "OPPS Non-Facility Fee", "OPPS Facility Fee"),
                                                                    col_types = readr::cols(
                                                                      Year = readr::col_double(),
                                                                      `Carrier Number` = readr::col_character(),
                                                                      Locality = readr::col_character(),
                                                                      `HCPCS Code` = readr::col_character(),
                                                                      Modifier = readr::col_character(),
                                                                      `Non-Facility Fee` = readr::col_double(),
                                                                      `Facility Fee` = readr::col_double(),
                                                                      'Filler' = readr::col_skip(),
                                                                      `PCTC Indicator` = readr::col_character(),
                                                                      `Status Code` = readr::col_character(),
                                                                      `Multiple Surgery Indicator` = readr::col_character(),
                                                                      `50% Therapy Reduction Amount (non-institutional)` = readr::col_character(),
                                                                      `50% Therapy Reduction Amount (institutional)` = readr::col_character(),
                                                                      `OPPS Indicator` = readr::col_character(),
                                                                      `OPPS Non-Facility Fee` = readr::col_double(),
                                                                      `OPPS Facility Fee` = readr::col_double()
                                                                    ))
    ))
    outputdb <- dplyr::slice(outputdb, -((nrow(outputdb)-3):nrow(outputdb)))
    unlink (paste(storage_path, zipped.txt.name, sep = '/')) # delete unzipped .txt
    if(!keep_downloads){
      deletepaths[x] <<- path.zip  # save paths for later cleanup
    }
    return(outputdb)
  })
  if(!keep_downloads){
    unlink(deletepaths)
    if (length(list.files(storage_path)) == 0){
      unlink(storage_path, recursive = T)
    }
  }
  return(mpfs_all)
}

join_mpfs <- function(mpfs_all, locality){
  if(length(mpfs_all) == 1) {
    res <- mpfs_all[[1]] 
    res <- dplyr::mutate(res, Modifier = as.factor(.data$Modifier))
    res <- dplyr::mutate(res, Modifier = dplyr::recode(.data$Modifier, "  " = "none"))
  } else{
    res <- Reduce(function(db1, db2){
      temp <- dplyr::left_join(db1, db2,
                               by = c('Year', 'Carrier Number', 'Locality',
                                      'HCPCS Code', 'Modifier', 'Status Code',
                                      'PCTC Indicator',
                                      'Multiple Surgery Indicator',
                                      '50% Therapy Reduction Amount (non-institutional)',
                                      '50% Therapy Reduction Amount (institutional)',
                                      'OPPS Indicator'))
      temp <- dplyr::mutate(temp,
                            'Facility Fee' = dplyr::coalesce(.data$`Facility Fee.y`,
                                                             .data$`Facility Fee.x`),
                            'Non-Facility Fee' = dplyr::coalesce(.data$`Non-Facility Fee.y`,
                                                                 .data$`Non-Facility Fee.x`),
                            'OPPS Facility Fee' = dplyr::coalesce(.data$`OPPS Facility Fee.y`,
                                                                  .data$`OPPS Facility Fee.x`),
                            'OPPS Non-Facility Fee' = dplyr::coalesce(.data$`OPPS Non-Facility Fee.y`,
                                                                      .data$`OPPS Non-Facility Fee.x`))
      temp <- dplyr::select(temp, -.data$`Facility Fee.x`, -.data$`Facility Fee.y`,
                            -.data$`Non-Facility Fee.x`, -.data$`Non-Facility Fee.y`,
                            -.data$`OPPS Facility Fee.x`, -.data$`OPPS Facility Fee.y`,
                            -.data$`OPPS Non-Facility Fee.x`, -.data$`OPPS Non-Facility Fee.y`)
      temp <- dplyr::full_join(temp, dplyr::anti_join(db2, db1, by = 'HCPCS Code'),
                               by = c("Year", "Carrier Number", "Locality", "HCPCS Code",
                                      "Modifier", "PCTC Indicator", "Status Code", 
                                      "Multiple Surgery Indicator",
                                      "50% Therapy Reduction Amount (non-institutional)",
                                      "50% Therapy Reduction Amount (institutional)",
                                      "OPPS Indicator", "Facility Fee",
                                      "Non-Facility Fee", "OPPS Facility Fee",
                                      "OPPS Non-Facility Fee")) # addend non-overlapping rows
      return(temp)
    }, mpfs_all)
    res<- dplyr::mutate(res, Modifier = as.factor(.data$Modifier))
    res<- dplyr::mutate(res, Modifier = dplyr::recode(.data$Modifier, "  " = "none"))
  }
  if(!missing(locality)){
    carrier.number <- substr(as.character(locality), 1, 5)
    localityid <- substr(as.character(locality), 6, 7)
    assertthat::assert_that(carrier.number %in% res$`Carrier Number`,
                            msg = 'Provided locality does not match entries in this database')
    assertthat::assert_that(localityid %in% res$Locality,
                            msg = 'Provided locality does not match entries in this database')
    res <- dplyr::filter(res,
                         .data$`Carrier Number` == carrier.number,
                         .data$`Locality` == localityid)
  }
  return(res)
}

#' Access Medicare Physician Fee Schedule
#' 
#' Use the CMS API to download the MPFS database for any year between
#' 2014 and 2020, inclusive.
#' 
#' @param year integer (min = 14; max = 20) indicating MPFS database year
#' @param storage_path path to storing downloaded files (temporarily if
#'   `keep_downloads` equals `FALSE`)
#' @param keep_downloads if `TRUE`, stores compressed CMS data to prevent
#'   re-downloading; if `FALSE`, deletes intermediate data after loading into R
#' @param locality 7-digit HCFS identification number; if not specified,
#'   will return entire MPFS database (all localities)
#' @return MPFS database for respective year and localities (data frame)
#' @examples
#' \dontrun{
#' mpfs20 <- get_mpfs(20, storage_path = 'storage', keep_downloads = TRUE)
#' mpfs20 <- get_mpfs(20, storage_path = 'storage', locality = '1520200')
#' }
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export
get_mpfs <- function(year,                       # last two digits of desired look-up year
                    storage_path,                # directory in which storage folder exists or should be created (default: current working dir)
                    keep_downloads = TRUE,       # if TRUE, downloaded files will not be deleted from storage folder, and will not need to be redownloaded for future operations.
                                                 # if FALSE, downloaded files will be removed once database is generated. storage folder will be deleted if empty
                    locality                     # optional: valid 7-digit HCFS identification number; if not specified, will output full database
                    ){
  if(!missing(locality)) {
    assertthat::assert_that(nchar(locality) == 7, msg = 'Locality code must be a valid 7-digit HCFS identification number')
  }
  assertthat::assert_that(14<year & year<=20, msg = 'year must be a two digit integer between 14 and 20')
  if(!dir.exists(storage_path)) dir.create(storage_path, showWarnings = FALSE) # create storage folder if it does not exist
  assertthat::assert_that(dir.exists(storage_path), msg = 'Storage folder not found or could not be created; check that provided storage path is valid and R has write permissions')
  # --------------------------------------------
  mpfs_all <- download_mpfs(year, storage_path, keep_downloads)
  if(!missing(locality)) {
    join_mpfs(mpfs_all, locality)
  } else {
    join_mpfs(mpfs_all)
  }
}
