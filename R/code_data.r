#' Italian Municipalities (Comuni) Codes and Names
#'
#' A dataset containing the official ISTAT codes and names of Italian municipalities,
#' along with their corresponding province and region codes. The boundaries and
#' codes are harmonized.
#'
#' @format A tibble with 7,869 rows and 4 variables:
#' \describe{
#'   \item{municipality_code}{ISTAT municipal code (numeric).}
#'   \item{municipality_name}{Name of the municipality (character).}
#'   \item{province_code}{ISTAT provincial/supramunicipal code linking to \code{province_code} (numeric).}
#'   \item{region_code}{ISTAT regional code linking to \code{region_code} (numeric).}
#' }
#' @source \url{https://www.istat.it/classificazione/codici-dei-comuni-delle-province-e-delle-regioni/}
"municipality_code"

#' Italian Provinces Codes and Names
#'
#' A dataset containing the official ISTAT codes, names, and abbreviations
#' of Italian provinces and metropolitan cities.
#'
#' @format A tibble with 110 rows and 4 variables:
#' \describe{
#'   \item{province_code}{ISTAT provincial/supramunicipal code (numeric).}
#'   \item{province_name}{Official name of the province or metropolitan city (character).}
#'   \item{province_abbreviation}{Standard two-letter abbreviation of the province (character).}
#'   \item{region_code}{ISTAT regional code linking to \code{region_code} (numeric).}
#' }
#' @source \url{https://www.istat.it/classificazione/codici-dei-comuni-delle-province-e-delle-regioni/}
"province_code"

#' Italian Regions Codes and Names
#'
#' A dataset containing the official ISTAT codes, names, and macro-regional
#' classifications of Italian regions.
#'
#' @format A tibble with 20 rows and 3 variables:
#' \describe{
#'   \item{region_code}{ISTAT regional code (numeric).}
#'   \item{region_name}{Official name of the region, including bilingual names where applicable (character).}
#'   \item{macro_region}{Geographical macro-region (e.g., 'North-West', 'North-East', 'Center', 'South', 'Islands') (character).}
#' }
#' @source \url{https://www.istat.it/classificazione/codici-dei-comuni-delle-province-e-delle-regioni/}
"region_code"
