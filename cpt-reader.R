# DON'T USE YET

# libraries
# --------------------------------------
#library('dplyr')
#library('assertthat')

# read in database
# --------------------------------------
#mpfs <- readr::read_csv('Ohio CPT DB.csv', col_names = T)     need to fix with updated DB from MPFS_lookup.R
# define functions
# --------------------------------------
# function that takes a a vector of HCPCS codes and corresponding modifiers and returns a vector 
# of the revenue per procedure for each code
cptlookup <-  function(data) {    # data frame containing vector of HCPCS codes, vector of corresponding modifiers, boolean vector
  # of whether procedures were performed at facility
  assertthat::assert_that(ncol(data)>=3, msg = 'Input must be a data frame with at least 3 columns')  # check input argument
  assertthat::assert_that(all(dplyr::pull(data, 1) %in% mpfs$`HCPCS Code`), msg = paste('HCPCS codes in rows', paste(which(!pull(data,1) %in% mpfs$`HCPCS Code`), collapse = ", "), "are not known"))
  assertthat::assert_that(all(dplyr::pull(data, 2) %in% mpfs$Modifier), msg = paste('Modifiers in rows', paste(which(!pull(data, 2) %in% mpfs$Modifier), collapse = ", "), "are not known"))
  assertthat::assert_that(is.logical(dplyr::pull(data,3)), msg = 'Vector of facility values must be boolean')
  #assert_that(all(is_logical))
  res <- lapply(1:nrow(data), function(x) {
    pay <- dplyr::filter(mpfs, `HCPCS Code` == data[[x, 1]], `Modifier` == data[[x, 2]])
    pay <- select(pay, 12:13)
    if (data[[x, 3]]) {return(pay[[1]])} # Facility = Facility Fee
      else {return(pay[[2]])} # Non-Facility = Non-Facility Fee
  })
  as.numeric(unlist(res)) # return vector of revenue per procedure
}
