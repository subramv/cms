# DON'T USE YET

# libraries
# --------------------------------------
library('tidyverse')
library('assertthat')

# read in database
# --------------------------------------
#mpfs <- readr::read_csv('Ohio CPT DB.csv', col_names = T)     need to fix with updated DB from MPFS_lookup.R
# define functions
# --------------------------------------
# function that takes a a vector of HCPCS codes and corresponding modifiers and returns a vector 
# of the revenue per procedure for each code
cptlookup <-  function(data) {    # data frame containing vector of HCPCS codes, vector of corresponding modifiers, boolean vector
  # of whether procedure was done inpatient, boolean vector of whether procedures were performed at facility
  assert_that(is.data.frame(data), msg = 'Input must be a data frame')  # check input argument
  assert_that(all(pull(data, 1) %in% mpfs$`HCPCS Code`), msg = paste('HCPCS codes in rows', paste(which(!pull(data,1) %in% mpfs$`HCPCS Code`), collapse = ", "), "are not known"))
  assert_that(all(pull(data, 2) %in% mpfs$Modifier), msg = paste('Modifiers in rows', paste(which(!pull(data, 2) %in% mpfs$Modifier), collapse = ", "), "are not known"))
  assert_that(is_logical(pull(data,3)), msg = 'Vector of inpatient values must be boolean')
  assert_that(is_logical(pull(data,4)), msg = 'Vector of facility values must be boolean')
  #assert_that(all(is_logical))
  res <- map(1:nrow(data), function(x) {
    pay <- mpfs %>% filter(`HCPCS Code` == data[[x, 1]], `Modifier` == data[[x, 2]]) %>% select(12:15)
    if (data[[x, 3]]) {
      if (data[[x, 4]]) {return(pay[[1]])} # Inpatient + Facility = Facility Fee
      else {return(pay[[2]])} # Inpatient + Non-Facility = Facility Fee
    }
    else{
      if (data[[x, 4]]) {return(pay[[4]])} # Outpatient + Facility = OPPS Facility Fee
      else {return(pay[[3]])} # Outpatient + Non-facility = OPPS Non-Facility Fee
    }
  })
  as.numeric(unlist(res)) # return vector of revenue per procedure
}
