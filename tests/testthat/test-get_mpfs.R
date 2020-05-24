testpath <- 'storage_test'
testlocality <- '1520200'
mpfs20 <- cms::get_mpfs(20, testpath, keep_downloads = TRUE)

test_that("get_mpfs stores downloads when keep_downloads = TRUE", {
  skip_on_cran()
  expect_true(dir.exists(testpath))
})

test_that("get_mpfs returns a data frame", {
  skip_on_cran()
  expect_s3_class(mpfs20, 'data.frame')
})

test_that("get_mpfs coalesces columns of revisions to avoid duplicates", {
  skip_on_cran()
  expect_identical(sort(colnames(mpfs20)), sort(c("Year", "Carrier Number", "Locality", "HCPCS Code", "Modifier", 
                                       "Non-Facility Fee", "Facility Fee", "PCTC Indicator", "Status Code", 
                                       "Multiple Surgery Indicator", "50% Therapy Reduction Amount (non-institutional)", 
                                       "50% Therapy Reduction Amount (institutional)", "OPPS Indicator", 
                                       "OPPS Non-Facility Fee", "OPPS Facility Fee")))
})

mpfs20_state <- cms::get_mpfs(20, testpath, keep_downloads = FALSE, 
                              locality = testlocality)

test_that("get_mpfs removes downloads when keep_downloads = FALSE", {
  skip_on_cran()
  expect_false(dir.exists(testpath))
})

test_that("get_mpfs keeps only the specified locality, if a 7-digit code is specified", {
  skip_on_cran()
  expect_identical(unique(mpfs20_state$`Carrier Number`), substr(testlocality, 1, 5))
  expect_identical(unique(mpfs20_state$Locality), substr(testlocality, 6, 7))
})


