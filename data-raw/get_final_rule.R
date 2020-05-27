# ------------------------------------------------------------------
# function to download relevant databases for PFS Final Rules
get_final_rule <- function(regulation.number,       # 4 digit regulation number corresponding to Final Rule of interest (1715 for 2020) 
                         storage.path = NULL,     # directory in which storage folder exists or should be created (default: current working dir)
                         keep.downloads = T       # if T, downloaded files will not be deleted from storage folder, and will not need to be redownloaded for future operations.
){
  storage.path = paste(storage.path, 'storage', sep = '')
  if(!dir.exists(storage.path)) dir.create(storage.path) # create storage folder if it does not exist
  assertthat::assert_that(dir.exists(storage.path), msg = 'Storage folder not found or could not be created; check that provided storage path is valid and R has write permissions')
  landingurl <- "https://www.cms.gov/Medicare/Medicare-Fee-for-Service-Payment/PhysicianFeeSched/PFS-Federal-Regulation-Notices?items_per_page=100&combine="
  baseurl <- "https://www.cms.gov"
  links <- xml2::read_html(landingurl)
  close(url(landingurl)) # close connection
  links <- rvest::html_nodes(links, "a")
  links <- rvest::html_attr(links, "href") 
  links <- links[grepl(paste(regulation.number, '-F',sep=''), links, ignore.case=T)]
  assertthat::assert_that(length(links)>0, msg = 'No downloads found for supplied regulation number')
  feeurl <- paste(baseurl, links, sep ='')
  links <- xml2::read_html(feeurl)
  close(url(feeurl)) # close connection
  links <- rvest::html_nodes(links, "a")
  links <- rvest::html_attr(links, "href")
  links <- grep("\\.zip", links, value = T)
  links <- links[c(3:6,13,17,21)]
  links <- paste(baseurl, links, sep = '')
  paths.zip <- paste(storage.path, sub(".*/", "", links), sep = '/')
  if (!keep.downloads){
    deletepaths <- vector(length = length(links), mode = 'character')
  }
  Map(function(u, d){
    if(!file.exists(d)) download.file(u, d)
    if(!keep.downloads){
      deletepaths[x] <<- d  # save paths for later cleanup
    }
  },
  links, paths.zip)
  print('Downloads complete')
}




