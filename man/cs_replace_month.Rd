% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/month_tools.R
\name{cs_replace_month}
\alias{cs_replace_month}
\title{Extract Month from Year-list Object}
\usage{
cs_replace_month(.data, month, monthData)
}
\arguments{
\item{.data}{A year list object}

\item{month}{A string name or abbreviation of a month, or its numeric value.
Acceptable inputs include, for example, "January", "january", "Jan",
"jan", and 1.}

\item{monthData}{A tibble containing a single month worth of crime data.}
}
\value{
An updated year-list object.
}
\description{
This function replaces a single month worth of crime data that
  has previously been extracted from a year-list object.
}
\examples{
# load example year-list object
load(system.file("testdata", "yearList17.rda", package = "compstatr", mustWork = TRUE))

# extract May
may17 <- cs_extract_month(yearList17, month = 5)

# replace
yearList17 <- cs_replace_month(yearList17, month = 5, monthData = may17)
yearList17 <- cs_replace_month(yearList17, month = "May", monthData = may17)

}
\seealso{
\code{\link{cs_extract_month}}
}
