## Resubmission
This is a resubmission. In this version, we have:

* removed the redundant phrase 'Tools for' from the package title in the DESCRIPTION file

* added undirected single quotes around 'CMS' when used in the package title/description in the DESCRIPTION file

* added a link (in <https:...> format) to the package description in the DESCRIPTION file where users can find more information about Medicare reimbursement (related to the package purpose)

* added automatic testing with a toy dataset (`mpfs20_oh` dataset) to account for the use of \dontrun{} around examples; we elected to keep \dontrun{} around our examples because they took up to a few minutes to run on our local machines

## Test environments
* local Windows 10, r-release
* Travis CI, r-release
* AppVeyor CI, r-release
* win-builder, r-devel

## R CMD check results
There were no ERRORs or WARNINGs.

There was 1 NOTE (new submission to CRAN).