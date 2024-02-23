#' Rate of spread at time t calculation
#'
#' @description Computes the Rate of Spread prediction based on fuel type and
#' FWI conditions at elapsed time since ignition. Equations are from listed
#' FCFDG (1992).
#'
#' All variables names are laid out in the same manner as Forestry Canada
#' Fire Danger Group (FCFDG) (1992). Development and Structure of the
#' Canadian Forest Fire Behavior Prediction System." Technical Report
#' ST-X-3, Forestry Canada, Ottawa, Ontario.
#'
#' @param FUELTYPE The Fire Behaviour Prediction FuelType
#' @param ROSeq    Equilibrium Rate of Spread (m/min)
#' @param HR       Time since ignition (hours)
#' @param CFB      Crown Fraction Burned
#'
#' @returns ROSt - Rate of Spread at time since ignition value
#'
#' @noRd

rate_of_spread_at_time <- function(FUELTYPE, ROSeq, HR, CFB) {
  # Eq. 72 - alpha constant value, dependent on fuel type
  alpha <- ifelse(
    FUELTYPE %in% c("C1", "O1A", "O1B", "S1", "S2", "S3", "D1"),
    0.115,
    0.115 - 18.8 * (CFB**2.5) * exp(-8 * CFB)
  )
  # Eq. 70 - Rate of Spread at time since ignition
  ROSt <- ROSeq * (1 - exp(-alpha * HR))
  return(ROSt)
}

.ROStcalc <- function(...) {
  .Deprecated("rate_of_spread_at_time")
  return(rate_of_spread_at_time(...))
}
