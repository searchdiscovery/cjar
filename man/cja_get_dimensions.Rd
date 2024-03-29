% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cja_get_dimensions.R
\name{cja_get_dimensions}
\alias{cja_get_dimensions}
\title{Get a list of dimensions in CJA}
\usage{
cja_get_dimensions(
  dataviewId = Sys.getenv("CJA_DATAVIEW_ID"),
  expansion = "description",
  includeType = NULL,
  locale = "en_US",
  debug = FALSE
)
}
\arguments{
\item{dataviewId}{\emph{Required} The id of the dataview for which to retrieve dimensions. If an environment variable called \code{CJA_DATAVIEW_ID} exists
in \code{.Renviron} or elsewhere and no \code{dataviewId} argument is provided, then the \code{CJA_DATAVIEW_ID} value will
be used. Use \code{\link[=cja_get_dataviews]{cja_get_dataviews()}} to get a list of available \code{dataviewId}.}

\item{expansion}{Comma-delimited list of additional segment metadata fields to include on response. See Details for all options available.}

\item{includeType}{Include additional segments not owned by user. Options include: "shared" "templates" "deleted" "internal"}

\item{locale}{Locale - Default: "en_US"}

\item{debug}{Used to help troubleshoot api call issues. Shows the call and result in the console}
}
\value{
A data frame of dimensions in a specified dataview
}
\description{
Retrieves a list of dimensions available in a specified dataviewId
}
\details{
\emph{Expansion} options can include the following:
"approved" "favorite" "tags" "usageSummary" "usageSummaryWithRelevancyScore"
"description" "sourceFieldId" "segmentable" "required" "hideFromReporting"
"hidden" "includeExcludeSetting" "fieldDefinition" "bucketingSetting"
"noValueOptionsSetting" "defaultDimensionSort" "persistenceSetting"
"storageId" "tableName" "dataSetIds" "dataSetType" "type" "schemaPath"
"hasData" "sourceFieldName" "schemaType" "sourceFieldType" "fromGlobalLookup"
"multiValued" "precision"
}
\examples{
\dontrun{
cja_get_dimensions(dataviewId = "dv_5f4f1e2572ea0000003ce262")
}
}
