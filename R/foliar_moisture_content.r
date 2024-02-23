#' Foliar Moisture Content Calculator
#'
#' @description Calculate Foliar Moisture Content on a specified day.
#' All variables names are laid out in the same manner as Forestry Canada
#' Fire Danger Group (FCFDG) (1992). Development and Structure of the
#' Canadian Forest Fire Behavior Prediction System." Technical Report
#' ST-X-3, Forestry Canada, Ottawa, Ontario.
#'
#' @param LAT    Latitude (decimal degrees)
#' @param LONG   Longitude (decimal degrees)
#' @param ELV    Elevation (metres)
#' @param DJ     Day of year (offeren referred to as julian date)
#' @param D0     Date of minimum foliar moisture content. _If D0, date of min
#'                   FMC, is not known then D0 = NULL._
#'
#' @return FMC: Foliar Moisture Content value
#' @noRd

foliar_moisture_content <- function(LAT, LONG, ELV, DJ, D0) {
  # Initialize vectors
  FMC <- rep(-1, length(LAT))
  LATN <- rep(0, length(LAT))
  # Calculate Normalized Latitude
  # Eqs. 1 & 3 (FCFDG 1992)
  LATN <- ifelse(
    D0 <= 0,
    ifelse(
      ELV <= 0,
      46 + 23.4 * exp(-0.0360 * (150 - LONG)),
      43 + 33.7 * exp(-0.0351 * (150 - LONG))
    ),
    LATN
  )
  # Calculate Date of minimum foliar moisture content
  # Eqs. 2 & 4 (FCFDG 1992)
  D0 <- ifelse(
    D0 <= 0,
    ifelse(
      ELV <= 0,
      151 * (LAT / LATN),
      142.1 * (LAT / LATN) + 0.0172 * ELV
    ),
    D0
  )
  # Round D0 to the nearest integer because it is a date
  D0 <- round(D0, 0)
  # Number of days between day of year and date of min FMC
  # Eq. 5 (FCFDG 1992)
  ND <- abs(DJ - D0)
  # Calculate final FMC
  # Eqs. 6, 7, & 8 (FCFDG 1992)
  FMC <- ifelse(
    ND < 30,
    85 + 0.0189 * ND^2,
    ifelse(
      ND >= 30 & ND < 50,
      32.9 + 3.17 * ND - 0.0288 * ND^2,
      120
    )
  )
  return(FMC)
}

.FMCcalc <- function(...) {
  .Deprecated("foliar_moisture_content")
  return(foliar_moisture_content(...))
}
