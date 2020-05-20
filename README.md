# cms R Package: Tools for Calculating CMS Medicare Reimbursement

[![Travis build status](https://travis-ci.org/subramv1/cms.svg?branch=master)](https://travis-ci.org/subramv1/cms)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/subramv1/cms?branch=master&svg=true)](https://ci.appveyor.com/project/subramv1/cms)

[![License: GPL v3](https://img.shields.io/badge/License-GPL%20v3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)
[![CRAN version](http://www.r-pkg.org/badges/version/cms)](https://CRAN.R-project.org/package=cms)
[![CRAN Downloads](http://cranlogs.r-pkg.org/badges/grand-total/cms)](https://CRAN.R-project.org/package=cms)

## Overview

The cms R package uses the CMS (Center for Medicare & Medicaid Services) API to provide useRs access to databases containing annually-updated Medicare reimbursement rates.
Data is available for all localities in the United States.
Currently, support is only provided for the Medicare Physician Fee Schedule (MPFS), but support will be expanded for other CMS databases in future versions.
In summary, cms implements programmatic access to healthcare reimbursement data via the CMS API and the R programming language.

## Installation

To install cms, run the following R code:
```r
# install from CRAN
install.packages("cms")

# install development version from GitHub
devtools::install_github("subramv/cms")

# install development version with vignettes
devtools::install_github("subramv/cms", build_vignettes = TRUE)
```

## Sample code

## Functionality

