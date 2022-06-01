library(testthat)
message("*** Running 'tests/installRequirements.R' ***")
source("tests/installRequirements.R")

testFiles <- list.files(file.path("tests"), "test-.*\\.R", full.names = TRUE)
for (testFile in testFiles) {
  message(sprintf("*** Running tests in '%s' ***", testFile))
  source(testFile)
}


# Note: testthat default structure does not work for non-packages: https://github.com/r-lib/testthat/issues/1490