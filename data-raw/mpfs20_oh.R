## code to prepare `mpfs_oh` dataset goes here
library(cms)
testpath <- 'storage_test'
testlocality <- '1520200'

mpfs20_oh <- cms::get_mpfs(20, testpath, keep_downloads = FALSE, 
                              locality = testlocality)
usethis::use_data(mpfs20_oh, overwrite = TRUE)
