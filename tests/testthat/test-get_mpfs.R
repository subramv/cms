library(cms)

test_that("get_mpfs stores downloads when keep_downloads = TRUE", {
  skip_on_cran()
  mpfs20 <- get_mpfs(20, 'storage_test', keep_downloads = TRUE)
  expect_true(dir.exists('storage_test'))
})

test_that("get_mpfs removes downloads when keep_downloads = FALSE", {
  skip_on_cran()
  mpfs20 <- get_mpfs(20, 'storage_test2', keep_downloads = FALSE)
  expect_false(dir.exists('storage_test2'))
})

test_that("get_mpfs returns a data frame", {
  expect_s3_class(mpfs20_oh, 'data.frame')
})

test_that("get_mpfs coalesces columns of revisions to avoid duplicates", {
  expect_identical(sort(colnames(mpfs20_oh)), sort(c("Year", "Carrier Number", "Locality", "HCPCS Code", "Modifier", 
                                       "Non-Facility Fee", "Facility Fee", "PCTC Indicator", "Status Code", 
                                       "Multiple Surgery Indicator", "50% Therapy Reduction Amount (non-institutional)", 
                                       "50% Therapy Reduction Amount (institutional)", "OPPS Indicator", 
                                       "OPPS Non-Facility Fee", "OPPS Facility Fee")))
})


test_that("get_mpfs keeps only the specified locality, if a 7-digit code is specified", {
  testlocality <- '1520200'
  expect_identical(unique(mpfs20_oh$`Carrier Number`), substr(testlocality, 1, 5))
  expect_identical(unique(mpfs20_oh$Locality), substr(testlocality, 6, 7))
})


