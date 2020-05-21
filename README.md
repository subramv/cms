# cms R Package: Tools for Calculating CMS Medicare Reimbursement

[![Travis build status](https://travis-ci.org/subramv/cms.svg?branch=master)](https://travis-ci.org/subramv/cms)
[![AppVeyor build status](https://ci.appveyor.com/api/projects/status/github/subramv/cms?branch=master&svg=true)](https://ci.appveyor.com/project/subramv/cms)

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

The following code pulls the 2019 MPFS national payment file for all localities:
```r
# load cms
library(cms)

#pull MPFS national payment file
mpfs19 <- get_mpfs(19)
```

More details can be found in the package vignettes. 

## Functionality

cms is designed to automate import and cleaning of CMS publically-available databases for useRs to use. 
Databases are downloaded to a user-specified directory and by default are stored as compressed source files for re-use.
At present, this functionality has been implemented for the MPFS. 


## Contributions
Please report any bugs, suggestions, etc. on the [issues page of the cms GitHub repository](https://github.com/subramv/cms/issues). 
Contributions (bug fixes, new features, etc.) are welcome via pull requests (generally from forked repositories).
