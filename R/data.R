#' Locality dictionary for 2020 Physician Fee Schedule
#' 
#' 
#' Asterisk indicates that payment locality is serviced by two carriers.
#' 
#' @format data frame with 113 rows and 5 columns:
#' \describe{
#'   \item{Carrier Number}{character; 5-digit carrier ID}
#'   \item{Locality}{character; 2-digit locality ID}
#'   \item{State}{character; uppercase, full U.S. state name}
#'   \item{Fee Schedule Area}{character; description of fee schedule area}
#'   \item{Counties}{character; counties included in Fee Schedule Area}
#' }
#' @source \url{https://www.cms.gov/Medicare/Medicare-Fee-for-Service-Payment/PhysicianFeeSched/Locality}
"locality_dict"