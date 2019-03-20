context("test cs_prep_year function")

# load data and save items to temp directory ------------------------------------------------
## load data
load(system.file("testdata", "year17.rda", package = "compstatr", mustWork = TRUE))

## create temp directory with data subdir
tmpdir <- tempdir()
fs::dir_create(paste0(tmpdir,"/data"))

## write files
readr::write_csv(jan17, path = paste0(tmpdir,"/data/january2017.CSV.html"))
readr::write_csv(feb17, path = paste0(tmpdir,"/data/february2017.CSV.html"))
readr::write_csv(mar17, path = paste0(tmpdir,"/data/march2017.CSV.html"))
readr::write_csv(apr17, path = paste0(tmpdir,"/data/april2017.CSV.html"))
readr::write_csv(may17, path = paste0(tmpdir,"/data/may2017.CSV.html"))
readr::write_csv(jun17, path = paste0(tmpdir,"/data/june2017.CSV.html"))
readr::write_csv(jul17, path = paste0(tmpdir,"/data/july2017.CSV.html"))
readr::write_csv(aug17, path = paste0(tmpdir,"/data/august2017.CSV.html"))
readr::write_csv(sep17, path = paste0(tmpdir,"/data/september2017.CSV.html"))
readr::write_csv(oct17, path = paste0(tmpdir,"/data/october2017.CSV.html"))
readr::write_csv(nov17, path = paste0(tmpdir,"/data/november2017.CSV.html"))
readr::write_csv(dec17, path = paste0(tmpdir,"/data/december2017.CSV.html"))

# test function ------------------------------------------------

test_that("correctly specified functions execute without error", {
  expect_error(cs_prep_year(path = paste0(tmpdir,"/data")), NA)
})

# test output ------------------------------------------------

## load data
load(system.file("testdata", "prepResults.rda", package = "compstatr", mustWork = TRUE))

## rename files again
fs::file_move(paste0(tmpdir,"/data/january2017.csv"), paste0(tmpdir,"/data/january2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/february2017.csv"), paste0(tmpdir,"/data/february2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/march2017.csv"), paste0(tmpdir,"/data/march2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/april2017.csv"), paste0(tmpdir,"/data/april2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/may2017.csv"), paste0(tmpdir,"/data/may2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/june2017.csv"), paste0(tmpdir,"/data/june2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/july2017.csv"), paste0(tmpdir,"/data/july2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/august2017.csv"), paste0(tmpdir,"/data/august2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/september2017.csv"), paste0(tmpdir,"/data/september2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/october2017.csv"), paste0(tmpdir,"/data/october2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/november2017.csv"), paste0(tmpdir,"/data/november2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/december2017.csv"), paste0(tmpdir,"/data/december2017.CSV.html"))

## create results
results <- cs_prep_year(path = paste0(tmpdir,"/data"), verbose = TRUE)

## compare
test_that("results created correctly", {
  expect_equal(prepResults, results)
})


# test parameters ------------------------------------------------

test_that("incorrect parameters trigger error", {
  expect_error(cs_prep_year(path = paste0(tmpdir,"/data"), verbose = "ham"),
               "The 'verbose' parameter only accepts 'TRUE' or 'FALSE' as valid arguments.")
})

## rename files again
fs::file_move(paste0(tmpdir,"/data/january2017.csv"), paste0(tmpdir,"/data/january2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/february2017.csv"), paste0(tmpdir,"/data/february2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/march2017.csv"), paste0(tmpdir,"/data/march2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/april2017.csv"), paste0(tmpdir,"/data/april2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/may2017.csv"), paste0(tmpdir,"/data/may2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/june2017.csv"), paste0(tmpdir,"/data/june2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/july2017.csv"), paste0(tmpdir,"/data/july2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/august2017.csv"), paste0(tmpdir,"/data/august2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/september2017.csv"), paste0(tmpdir,"/data/september2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/october2017.csv"), paste0(tmpdir,"/data/october2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/november2017.csv"), paste0(tmpdir,"/data/november2017.CSV.html"))
fs::file_move(paste0(tmpdir,"/data/december2017.csv"), paste0(tmpdir,"/data/december2017.CSV.html"))

## add additional files
readr::write_csv(dec17, path = paste0(tmpdir,"/data/december2018.CSV.html"))

test_that("too many files trigger error", {
  expect_error(cs_prep_year(path = paste0(tmpdir,"/data")),
               "There are too many files in the specified folder. Edit crime files in yearly batches of 12 monthly files.")
})

## delete files
fs::file_delete(paste0(tmpdir,"/data/december2017.CSV.html"))
fs::file_delete(paste0(tmpdir,"/data/december2018.CSV.html"))

test_that("too few files triggers warning", {
  expect_warning(cs_prep_year(path = paste0(tmpdir,"/data")),
               "There are fewer than 12 files in the specified folder. You are only editing a partial year.")
})

# final options ------------------------------------------------
unlink(tmpdir)