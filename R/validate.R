#' Validate Year List Object
#'
#' @description Data from SLMPD are released with a number of problems that
#'     \code{cs_validate} is designed to identify.
#'
#' @details \code{cs_validate} performs a total of five checks on the given
#'     year-list object. Each test is summarized in the \code{verbose = TRUE} output:
#'
#' \describe{
#'   \item{valMonth}{Each tibble within a year-list is named for the month it represents.
#'       Does the named month match the month that the data represent?}
#'   \item{valYear}{Does the year provided for the \code{year} argument match the year
#'       that the data represent?}
#'   \item{oneMonth}{Does each tibble represent only one month of data?}
#'   \item{varCount}{Does each tibble have the correct number of variables (20)?}
#'   \item{valVars}{Does each tibble have the correct variable names?}
#' }
#'
#'   For all months prior to 2013 and approximately half of the months during 2013,
#'   SLMPD data are released with 18 variables. For one month, May 2017, the data
#'   are released with 26 variables. These problems are identified most easily
#'   by using \code{cs_validate}.
#'
#' @usage cs_validate(.data, year, verbose = FALSE)
#'
#' @param .data A tbl
#' @param year A string representing the year being checked, e.g. \code{"2008" }
#' @param verbose A logical scalar. If \code{TRUE}, a full validation report summarizing
#'     results will be returned. If \code{FALSE}, a single value will be returned.
#'
#' @return A tibble with validation results.
#'
#' @examples
#' # load example year-list object
#' load(system.file("testdata", "yearList17.rda", package = "compstatr", mustWork = TRUE))
#'
#' # simple validation
#' cs_validate(yearList17, year = 2017)
#'
#' # verbose validation
#' cs_validate(yearList17, year = 2017, verbose = TRUE)
#'
#' @importFrom dplyr as_tibble
#' @importFrom dplyr mutate
#' @importFrom dplyr rename
#' @importFrom dplyr select
#' @importFrom dplyr %>%
#' @importFrom rlang quo_name
#' @importFrom rlang enquo
#' @importFrom stringr str_sub
#'
#' @export
cs_validate <- function(.data, year, verbose = FALSE){

  monthVal <- cs_checkNames(.data)

  #quote input variables

  year <- rlang::quo_name(rlang::enquo(year))

  # initial logic checks
  if (monthVal == "january"){

    warning('The given year list object does not include January.')
    result <- FALSE

  } else if (monthVal == "duplicates"){

    warning('The given year list object has a duplicate entry for at least one month.')
    result <- FALSE

  } else if (monthVal == "missing"){

    warning('The given year list object does not contain all consecutive months between January and the last given month.')
    result <- FALSE

  } else if (monthVal == "valid"){

    result <- TRUE

  }

  # check internal characteristics of each month in year list object
  if (result == TRUE){

    # iterate over year list object to produce logic check results
    .data %>%
      purrr::map(cs_checkMonth) -> result

    # add month name as observation
    for (i in 1:length(result)){

      result[[i]] <- c(result[[i]], names(result[i]))

    }

    # convert results to tibble
    result <- dplyr::as_tibble(data.frame(matrix(unlist(result),
                                                 nrow = length(result),
                                                 byrow = TRUE),
                                          stringsAsFactors=FALSE))

    # clean results tibble
    result <- cs_cleanResults(result)

    # validate months
    result <- cs_matchMonths(result)

    # validate year
    result <- cs_matchYear(result, year = as.integer(year))

    # structure returned results
    if (verbose == FALSE){

      if (all(result$oneMonth) == FALSE | all(result$valMonth) == FALSE |
          all(result$valYear) == FALSE | all(result$varCount) == FALSE |
          all(result$valVars) == FALSE){

        result <- FALSE

      } else if (all(result$oneMonth) == TRUE & all(result$valMonth) == TRUE &
                 all(result$valYear) == TRUE & all(result$varCount) == TRUE &
                 all(result$valVars) == TRUE){

        result <- TRUE

      }
    }
  }

  # return output
  return(result)

}

# Validate Number of Months
#
# @description This checks the list of months to make sure that there are either
#     12 unique month entries or, if there are fewer than 12, that there are no
#     missing missing months between January and the last month loaded.
#
# @details For year list objects with fewer than 12 months, this confirms that
#     data for January are present. It then ensures that there are no months
#     between January and the last month entered. For example, if the first six
#     months of data were loaded - i.e. through June - this function would
#     ensure that there were no months missing between January and June.
#
# @param .data A yaer list object
#
cs_checkNames <- function(.data){

  # create list of months present in year list object
  months <- names(.data)

  # ensure that January is present
  jan <- ("January" %in% months)

  # ensure that January is present
  if (jan == FALSE) {

    result <- "january"

  } else if (jan == TRUE){

    # ensure that there are no duplicates
    uniqueMonths <- unique(months)
    uniqueTest <- (length(months) == length(uniqueMonths))

    if (uniqueTest == FALSE){

      result <- "duplicates"

    } else if (uniqueTest == TRUE){

      # check that all necessary months are present
      correctMonths <- cs_validateNames(names = months)

      if (correctMonths == FALSE){

        result <- "missing"

      } else if (correctMonths == TRUE){

        result <- "valid"

      }
    }
  }

  # return output
  return(result)

}

# Validate Names of Months
#
# @description Given the names of months in the year list object,
#     are all months that should be present included?
#
# @param names Vector of names of months from year list object
#
cs_validateNames <- function(names){

  # create master list of all months
  allNames <- c("January", "February", "March", "April", "May", "June", "July", "August", "September",
                "October", "November", "December")

  # get number of months from year list object
  num <- length(names)

  # cut master list down to number of months in year list object
  testNames <- allNames[1:num]

  # test whether master list and year list object months are identical
  testResult <- identical(sort(names),sort(testNames))

  # return result
  return(testResult)

}


# Check Month of Year List Object for Correct Properties
#
# @description  This checks a single month for the correct properties
#
# @param monthItem A single item in a year list object
#
cs_checkMonth <- function(monthItem){

  a <- as.character(cs_checkCodedMonth(monthItem))
  b <- as.character(cs_identifyMonth(monthItem, read = FALSE))


  if (ncol(monthItem) == 20){

    c <- "TRUE"

  } else if (ncol(monthItem) == 18 | ncol(monthItem) == 26){

    c <- "FALSE"

  } else {

    c <- "ERROR"

  }

  d <- cs_checkVarNames(monthItem)
  e <- cs_identifyYear(monthItem)

  out <- c(a,b,c,d,e)

  # return output
  return(out)

}


# Check Month for Single Coded Month Value
#
# @description Ensure that there is only one coded month value per year list object item
#
# @param monthItem A single item in a year list object
#
cs_checkCodedMonth <- function(monthItem){

  # check to see if coded month values are identical
  if (length(monthItem) == 18){

    monthVal <- length(unique(monthItem$month_reportedto_mshp))

  } else if (length(monthItem) == 20){

    monthVal <- length(unique(monthItem$coded_month))

  } else if (length(monthItem) == 26){

    monthVal <- length(unique(monthItem$coded_month))

  }

  # construct result
  if (monthVal == 1){

    result <- TRUE

  } else if (monthVal > 1){

    result <- FALSE

  }

  return(result)

}


# Check Variable Names
#
# @description Checks to make sure variable names are correct if there are 20 variables in month
#
# @param monthItem A single item in a year list object
#
cs_checkVarNames <- function(monthItem){

  if (ncol(monthItem) == 20){

    validVars <- c("complaint", "coded_month", "date_occur", "flag_crime", "flag_unfounded",
                   "flag_administrative", "count", "flag_cleanup", "crime", "district",
                   "description", "ileads_address", "ileads_street", "neighborhood", "location_name",
                   "location_comment", "cad_address", "cad_street", "x_coord", "y_coord")

    testVars <- colnames(monthItem)

    if (all(testVars == validVars) == TRUE) {

      result <- "TRUE"

    } else if (all(testVars == validVars) == FALSE) {

      result <- "FALSE"

    }

  } else if (ncol(monthItem) != 20){

    result <- "NA"

  }

  # return output
  return(result)

}

# Clean Results Tibble
#
# @description Converts messy results output to clean output
#
# @param .data A result tibble
#
cs_cleanResults <- function(.data){

  # undefined global variables
  X1 = X2 = X3 = X4 = X5 = X6 = oneMonth = monthNum = varCount = valVars = namedMonth = codedYear = NULL

  # rename variables
  .data %>%
    dplyr::rename(oneMonth = X1) %>%
    dplyr::rename(monthNum = X2) %>%
    dplyr::rename(varCount = X3) %>%
    dplyr::rename(valVars = X4) %>%
    dplyr::rename(namedMonth = X6) %>%
    dplyr::rename(codedYear = X5) -> out

  # clean data
  out %>%
    dplyr::mutate(oneMonth = as.logical(oneMonth)) %>%
    dplyr::mutate(monthNum = as.integer(monthNum)) %>%
    dplyr::mutate(varCount = ifelse(varCount == "ERROR", NA, varCount)) %>%
    dplyr::mutate(varCount = as.logical(varCount)) %>%
    dplyr::mutate(valVars = ifelse(valVars == "NA", NA, valVars)) %>%
    dplyr::mutate(valVars = as.logical(valVars)) -> out

  # limit variables returned
  out <- dplyr::select(out, namedMonth, monthNum, oneMonth, codedYear, varCount, valVars)

  # return output
  return(out)

}

# Logic Check for Named and Coded Month
#
# @description Updates test result tibble with results of logic check that compares the
#     data from the named month with the data from the coded month.
#
# @param .data A result tibble
#
cs_matchMonths <- function(.data){

  # undefined global variables
  namedMonth = codedMonth = valMonth = monthNum = NULL

  # clean data and perform logic check
  .data %>%
    dplyr::mutate(codedMonth = dplyr::case_when(
      monthNum == 1 ~ "January",
      monthNum == 2 ~ "February",
      monthNum == 3 ~ "March",
      monthNum == 4 ~ "April",
      monthNum == 5 ~ "May",
      monthNum == 6 ~ "June",
      monthNum == 7 ~ "July",
      monthNum == 8 ~ "August",
      monthNum == 9 ~ "September",
      monthNum == 10 ~ "October",
      monthNum == 11 ~ "November",
      monthNum == 12 ~ "December"
    )) %>%
    dplyr::mutate(valMonth = ifelse(namedMonth == codedMonth, TRUE, FALSE)) %>%
    dplyr::select(namedMonth, codedMonth, valMonth, dplyr::everything()) %>%
    dplyr::arrange(monthNum) %>%
    dplyr::select(-monthNum) -> out

  # return output
  return(out)

}

# Extract Year of a Given Year List Object Item
#
# @description  This uses the value of the first observation's coded month as the basis for
#     identifying which month the data are from.
#
# @param monthItem A single month from a year list object
#
cs_identifyYear <- function(monthItem){

  # depending on number of columns, the CodedMonth variable is named differently
  # the if elseif statements pull the first value from CodedMonth

  if (length(monthItem) == 18){

    yearVal <- monthItem$month_reportedto_mshp[1]

  } else if (length(monthItem) == 20 | length(monthItem) == 26){

    yearVal <- monthItem$coded_month[1]

  }

  # extract the last two digits from the coded month value
  year <- stringr::str_sub(yearVal, start = 1, end = 4)

  # return output
  return(year)

}

# Logic Check for Named and Coded Month
#
# @description Updates test result tibble with results of logic check that compares the
#     data from the given year argument with the data from the coded year.
#
# @param .data A result tibble
#
cs_matchYear <- function(.data, year){

  # undefined global variables
  namedMonth = codedMonth = valMonth = codedYear = valYear = NULL

  # clean data and perform logic check
  .data %>%
    dplyr::mutate(codedYear = as.integer(codedYear)) %>%
    dplyr::mutate(valYear = ifelse(codedYear == year, TRUE, FALSE)) %>%
    dplyr::select(namedMonth, codedMonth, valMonth, codedYear, valYear, dplyr::everything()) -> out

  # return output
  return(out)

}
