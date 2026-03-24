#' Download and load itapop data for a specific year
#'
#' This function downloads and loads annual datasets of the harmonized Italian resident population.
#' Each dataset (\code{respop_2002} through \code{respop_2025}) follows the same
#' structure and contains demographic counts at the municipal level.
#'
#' @param year Integer. The year of the resident population data to download (e.g., 2002 to 2025).
#' @param force_download Logical. If \code{TRUE}, bypasses the interactive prompt and forces the download. Defaults to \code{FALSE}.
#'
#' @return A \code{data.table} containing the requested data, or \code{NULL} if the download is cancelled.
#' The returned dataset contains the following variables:
#' \describe{
#'   \item{year}{Reference year (integer).}
#'   \item{region_code}{ISTAT regional code (numeric).}
#'   \item{province_code}{ISTAT provincial/supramunicipal code (numeric).}
#'   \item{municipality_code}{ISTAT municipal code, harmonized to 2026 boundaries (numeric).}
#'   \item{citizenship}{Citizenship status: 'italian' or 'foreign' (factor).}
#'   \item{sex}{Gender: 'male' or 'female' (factor).}
#'   \item{age}{Age in years, from 0 to 100 (numeric).}
#'   \item{resident_population_jan_1}{Population count on January 1st (numeric).}
#'   \item{average_population}{Mean population for the year (numeric). NA for the last year of the series.}
#' }
#'
#' @source \url{https://demo.istat.it/}
#' @export
#'
#' @examples
#' \dontrun{
#' # Interactive usage (will ask for permission if not cached)
#' df_2022 <- download_itapop_data(2022)
#'
#' # Automated usage (forces download without asking)
#' df_2023 <- download_itapop_data(2023, force_download = TRUE)
#' }
download_itapop_data <- function(year, force_download = FALSE) {
  # 1. Input validation
  valid_years <- 2002:2025
  if (!year %in% valid_years) {
    stop("Invalid year. Please provide a year between 2002 and 2025.")
  }

  file_name <- paste0("respop_", year, ".rda")

  # 2. Cache management (CRAN Friendly)
  cache_dir <- tools::R_user_dir("itapop", which = "cache")
  if (!dir.exists(cache_dir)) {
    dir.create(cache_dir, recursive = TRUE)
  }

  dest_file <- file.path(cache_dir, file_name)

  # 3. Download logic
  if (!file.exists(dest_file)) {
    if (!force_download) {
      if (interactive()) {
        msg <- sprintf("The dataset for year %s (approx. 3 MB) is not in cache. Do you want to download it now?", year)
        ans <- utils::menu(c("Yes", "No"), title = msg)

        if (ans != 1) {
          message("Download cancelled.")
          return(invisible(NULL))
        }
      } else {
        message("Non-interactive session. Use force_download = TRUE to proceed with the download.")
        return(invisible(NULL))
      }
    }

    # Dynamic URL for the GitHub release
    url <- paste0(
      "https://github.com/giovannitinervia9/itapop/releases/download/v0.1.0-data/",
      file_name
    )

    message("Downloading ", file_name, "...")

    tryCatch(
      {
        utils::download.file(url, destfile = dest_file, mode = "wb", quiet = TRUE)
        message("Download completed and saved to cache.")
      },
      error = function(e) {
        if (file.exists(dest_file)) file.remove(dest_file)
        stop("Error downloading from GitHub repository: ", e$message)
      }
    )
  } else {
    message("Data already in cache. Loading...")
  }

  # 4. Load data (.rda) without polluting the Global Environment
  temp_env <- new.env()
  load(dest_file, envir = temp_env)

  obj_name <- ls(temp_env)[1]

  return(temp_env[[obj_name]])
}
