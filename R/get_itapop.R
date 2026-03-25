#' Get and aggregate Italian resident population data
#'
#' This is the main high-level function of the \code{itapop} package. It automatically
#' downloads (or loads from cache) the requested years of data and aggregates them
#' according to the user's specifications.
#'
#' By default, the function returns the most detailed data available (municipality level,
#' distinguishing by sex, citizenship, and single year of age). Set the demographic
#' arguments to \code{FALSE} to aggregate the population counts over those dimensions.
#'
#' @param years Integer vector. The year(s) of data to retrieve (e.g., \code{2019:2022}).
#' @param geo_level Character. The desired geographic level of detail.
#'   Can be one of \code{"municipality"} (default), \code{"province"}, \code{"region"}, or \code{"national"}.
#' @param by_sex Logical. Should the population be split by sex? Default is \code{TRUE}.
#' @param by_citizenship Logical. Should the population be split by citizenship? Default is \code{TRUE}.
#' @param by_age Logical. Should the population be split by single year of age? Default is \code{TRUE}.
#' @param include_names Logical. If \code{TRUE}, automatically joins the aggregated data
#'   with the official ISTAT geographic names (regions, provinces, municipalities). Default is \code{TRUE}.
#' @param force_download Logical. If \code{TRUE}, bypasses the interactive prompt and forces the download of missing datasets. Defaults to \code{FALSE}.
#' @param overwrite Logical. If \code{TRUE}, forces the redownload of the datasets even if they already exist in the cache. Defaults to \code{FALSE}.
#' @param as_data_frame Logical. If \code{TRUE}, returns a base R \code{data.frame} instead of a \code{data.table}. Defaults to \code{TRUE}.
#'
#' @return A \code{data.table} (or \code{data.frame} if \code{as_data_frame = TRUE}) containing the requested and aggregated population counts,
#'   optionally enriched with geographic names.
#' @importFrom data.table rbindlist as.data.table is.data.table setorderv setDF
#' @export
#'
#' @examples
#' \dontrun{
#' # 1. Get raw, fully detailed data for 2022
#' df_2022_raw <- get_itapop(2022)
#'
#' # 2. Get national population for 2020-2022, aggregated by age and sex
#' df_nat <- get_itapop(
#'   years = 2020:2022,
#'   geo_level = "national",
#'   by_citizenship = FALSE
#' )
#'
#' # 3. Get regional totals for 2023 with geographic names included
#' df_reg_names <- get_itapop(2023,
#'   geo_level = "region",
#'   by_sex = FALSE,
#'   by_citizenship = FALSE,
#'   by_age = FALSE,
#'   include_names = TRUE
#' )
#'
#' # 4. Force update of cached data for 2023 and return as a base data.frame
#' df_2023_updated <- get_itapop(2023, overwrite = TRUE, as_data_frame = TRUE)
#' }
get_itapop <- function(
    years,
    geo_level = c("municipality", "province", "region", "national"),
    by_sex = TRUE,
    by_citizenship = TRUE,
    by_age = TRUE,
    include_names = TRUE,
    force_download = FALSE,
    overwrite = FALSE,
    as_data_frame = TRUE) {
  geo_level <- match.arg(geo_level)

  # 1. Fetch data for all requested years
  data_list <- lapply(years, function(y) {
    download_itapop_data(year = y, force_download = force_download, overwrite = overwrite)
  })
  gc()

  # Clean up any NULLs (if download was cancelled)
  data_list <- Filter(Negate(is.null), data_list)

  if (length(data_list) == 0) {
    message("No data loaded. Exiting.")
    return(invisible(NULL))
  }

  dt <- data.table::rbindlist(data_list)

  # 2. Determine grouping columns
  by_cols <- "year"

  if (geo_level == "municipality") {
    by_cols <- c(by_cols, "region_code", "province_code", "municipality_code")
  } else if (geo_level == "province") {
    by_cols <- c(by_cols, "region_code", "province_code")
  } else if (geo_level == "region") {
    by_cols <- c(by_cols, "region_code")
  }

  if (by_sex) by_cols <- c(by_cols, "sex")
  if (by_citizenship) by_cols <- c(by_cols, "citizenship")
  if (by_age) by_cols <- c(by_cols, "age")

  # 3. Aggregation logic
  cols_to_sum <- c("resident_population_jan_1", "average_population")
  cols_to_sum <- intersect(cols_to_sum, names(dt))

  if (length(by_cols) > 0) {
    agg_dt <- dt[, lapply(.SD, sum, na.rm = TRUE), by = by_cols, .SDcols = cols_to_sum]
  } else {
    agg_dt <- dt[, lapply(.SD, sum, na.rm = TRUE), .SDcols = cols_to_sum]
  }

  # 4. Join Geographic Names if requested
  if (include_names && geo_level != "national") {
    # We use get() to retrieve the internal package datasets safely
    # and convert them to data.table for fast merging

    if (geo_level %in% c("municipality", "province", "region")) {
      reg_dt <- data.table::as.data.table(get("region_code", envir = asNamespace("itapop")))
      agg_dt <- merge(agg_dt, reg_dt, by = "region_code", all.x = TRUE)
    }

    if (geo_level %in% c("municipality", "province")) {
      prov_dt <- data.table::as.data.table(get("province_code", envir = asNamespace("itapop")))
      agg_dt <- merge(agg_dt, prov_dt, by = c("region_code", "province_code"), all.x = TRUE)
    }

    if (geo_level == "municipality") {
      mun_dt <- data.table::as.data.table(get("municipality_code", envir = asNamespace("itapop")))
      agg_dt <- merge(agg_dt, mun_dt, by = c("region_code", "province_code", "municipality_code"), all.x = TRUE)
    }
  }

  # Sort finally for a clean output
  if (length(by_cols) > 0) {
    data.table::setorderv(agg_dt, by_cols)
  }

  # 5. Convert to data.frame if requested
  if (as_data_frame) {
    data.table::setDF(agg_dt)
  }

  return(agg_dt)
}
