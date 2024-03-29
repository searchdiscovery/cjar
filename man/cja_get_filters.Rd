% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cja_get_filters.R
\name{cja_get_filters}
\alias{cja_get_filters}
\title{Get a paginated list of filters in CJA}
\usage{
cja_get_filters(
  expansion = NULL,
  includeType = "all",
  dataviewIds = NULL,
  ownerId = NULL,
  filterByIds = NULL,
  toBeUsedInRsid = NULL,
  locale = "en_US",
  name = NULL,
  filterByModifiedAfter = NULL,
  cached = TRUE,
  pagination = TRUE,
  limit = 10,
  page = 0,
  sortDirection = "ASC",
  sortProperty = "id",
  debug = FALSE
)
}
\arguments{
\item{expansion}{Comma-delimited list of additional segment metadata fields to include on response. See Details for all options available}

\item{includeType}{Include additional filters not owned by user. Default is "all". Options include: "shared" "templates" "deleted" "internal"}

\item{dataviewIds}{Filter list to only include filters tied to the specified data group ID list (comma-delimited)}

\item{ownerId}{Filter list to only include filters owned by the specified imsUserId}

\item{filterByIds}{Filter list to only include filters in the specified list (comma-delimited list of IDs). This has filtered Ids from tags, approved, favorites and user specified Ids list.}

\item{toBeUsedInRsid}{The report suite where the segment is intended to be used. This report suite will be used to determine things like compatibility and permissions.}

\item{locale}{Locale - Default: "en_US"}

\item{name}{Filter list to only include filters that contains the Name. Can only be a string value.}

\item{filterByModifiedAfter}{Filter list to only include filters modified since this date. 'yyyy-mm-dd' format}

\item{cached}{Return cached results. TRUE by default.}

\item{pagination}{Return paginated results}

\item{limit}{Number of results per page}

\item{page}{Page number (base 0 - first page is "0")}

\item{sortDirection}{Sort direction ('ASC' or 'DESC'). 'ASC' is default.}

\item{sortProperty}{Property to sort by (name, modified_date, performanceScore, id is currently allowed). 'id' is default}

\item{debug}{Used to help troubleshoot api call issues. Shows the call and result in the console}
}
\value{
A data frame of company ids and company names
}
\description{
Retrieves a paginated list of filters, also known as \code{segments} in Adobe Analytics.
}
\details{
\emph{Expansion} options can include the following:
"compatibility", "definition", "internal", "modified", "isDeleted",
"definitionLastModified", "createdDate", "recentRecordedAccess",
"performanceScore", "owner", "dataId", "ownerFullName", "dataName",
"sharesFullName", "approved", "favorite", "shares", "tags", "usageSummary",
"usageSummaryWithRelevancyScore"
}
\examples{
\dontrun{
cja_get_filters()
}
}
