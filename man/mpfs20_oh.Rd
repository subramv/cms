% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/data.R
\docType{data}
\name{mpfs20_oh}
\alias{mpfs20_oh}
\title{2020 Physician Fee Schedule, Ohio}
\format{
data frame with 8994 rows and 15 columns:
\describe{
  \item{Year}{numeric; 4-digit year}
  \item{Carrier Number}{character; 5-digit carrier ID}
  \item{Locality}{character; 2-digit locality ID}
  \item{HCPCS Code}{character; CPT or level 2 HCPCS code for procedure}
  \item{Modifier}{factor; payment schedule modifier}
  \item{PCTC Indicator}{character; Professional Component/Technical Component
  Indicator}
  \item{Status Code}{character; Medicare status code (e.g. A = Active code)}
  \item{Multiple Surgery Indicator}{character; indicator of payment
  adjustment rules for multiple procedures}
  \item{50\% Therapy Reduction Amount (non-institutional)}{numeric; multiple
  procedure therapy reduction amount (non-institutional)}
  \item{50\% Therapy Reduction Amount (institutional)}{numeric; multiple
  procedure therapy reduction amount (institutional)}
  \item{OPPS Indicator}{character; indicator as to whether Outpatient
  Prospective Payment System applies}
  \item{Facility Fee}{numeric; reimbursement for procedure performed in a
  facility setting} 
  \item{Non-Facility Fee}{numeric; reimbursement for procedure performed in a
  non-facility setting}
  \item{OPPS Facility Fee}{numeric; reimbursement for procedure performed in
  a facility setting if OPPS applies} 
  \item{OPPS Non-Facility Fee}{numeric; reimbursement for procedure performed 
  in a non-facility setting if OPPS applies}
}
}
\source{
\url{https://www.cms.gov/Medicare/Medicare-Fee-for-Service-Payment/PhysicianFeeSched/PFS-National-Payment-Amount-File}
}
\usage{
mpfs20_oh
}
\description{
2020 Physician Fee Schedule, Ohio
}
\keyword{datasets}
