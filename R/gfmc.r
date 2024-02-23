#' Grass Fuel Moisture Code
#'
#' @description \code{gfmc} calculates both the moisture content of the surface
#' of a fully cured matted grass layer and also an equivalent Grass Fuel
#' Moisture Code (gfmc) (Wotton, 2009) to create a parallel with the hourly ffmc
#' (see the \code{\link{fwi}} and \code{\link{hffmc}}functions). The calculation
#' is based on hourly (or sub-hourly) weather observations of temperature,
#' relative humidity, wind speed, rainfall, and solar radiation. The user must
#' also estimate an initial value of the gfmc for the layer. This function
#' could be used for either one weather station or multiple weather stations.
#'
#' The Canadian Forest Fire Danger Rating System (CFFDRS) is used throughout
#' Canada, and in a number of countries throughout the world, for estimating
#' fire potential in wildland fuels. This new Grass Fuel Moisture Code (GFMC)
#' is an addition (Wotton 2009) to the CFFDRS and retains the structure of that
#' System's hourly Fine Fuel Moisture Code (HFFMC) (Van Wagner 1977). It tracks
#' moisture content in the top 5 cm of a fully-cured and fully-matted layer of
#' grass and thus is representative of typical after winter conditions in areas
#' that receive snowfall.  This new moisture calculation method outputs both
#' the actual moisture content of the layer and also the transformed moisture
#' Code value using the FFMC's FF-scale.  In the CFFDRS the moisture codes are
#' in fact relatively simple transformations of actual moisture content such
#' that decreasing moisture content (increasing dryness) is indicated by an
#' increasing Code value. This moisture calculation uses the same input weather
#' observations as the hourly FFMC, but also requires an estimate of solar
#' radiation incident on the fuel.
#'
#' @param input A dataframe containing input variables of daily noon weather
#' observations. Variable names have to be the same as in the following list,
#' but they are case insensitive. The order in which the input variables are
#' entered is not important.
#'
#' \tabular{lll}{
#' \var{id} \tab (optional) \tab Batch Identification\cr
#' \var{temp} \tab (required) \tab Temperature (centigrade)\cr
#' \var{rh} \tab (required) \tab Relative humidity (\%)\cr
#' \var{ws} \tab (required) \tab 10-m height wind speed (km/h)\cr
#' \var{prec} \tab (required) \tab 1-hour rainfall (mm)\cr
#' \var{isol} \tab (required) \tab Solar radiation (kW/m^2)\cr
#' \var{mon} \tab (recommended) \tab Month of the year (integer' 1-12)\cr
#' \var{day} \tab (optional) \tab Day of the month (integer)\cr }
#' @param GFMCold Previous value of GFMC (i.e. value calculated at the previous
#' time step)[default is 85 (which corresponds to a moisture content of about
#' 16\%)]. On the first calculation this is the estimate of the GFMC value at
#' the start of the time step. The \code{GFMCold} argument can accept a single
#' initial value for multiple weather stations, and also accept a vector of
#' initial values for multiple weather stations.  NOTE: this input represents
#' the CODE value, not a direct moisture content value. The CODE values in the
#' Canadian FWI System increase within decreasing moisture content. To roughly
#' convert a moisture content value to a CODE value on the FF-scale (used in
#' the FWI Systems FFMC) use \code{GFMCold} =101-gmc (where gmc is moisture
#' content in \%)
#'
#' @param time.step Time step (hour) [default 1 hour]
#' @param roFL The nominal fuel load of the fine fuel layer, default is 0.3
#' kg/m^2
#' @param batch Whether the computation is iterative or single step, default is
#' TRUE. When \code{batch=TRUE}, the function will calculate hourly or
#' sub-hourly GFMC for one weather station over a period of time iteratively.
#' If multiple weather stations are processed, an additional "id" column is
#' required in the input to label different stations, and the data needs to be
#' sorted by time sequence and "id".  If \code{batch=FALSE}, the function
#' calculates only one time step (1 hour) base on either the previous hourly
#' GFMC or the initial start value.
#' @param out Output format, default is "GFMCandMC", which contains both GFMC
#' and moisture content (MC) in a data.frame format. Other choices include:
#' "GFMC", "MC", and "ALL", which include both the input and GFMC and MC.
#' @return \code{gfmc} returns GFMC and moisture content (MC) values
#' collectively (default) or separately.
#' @author Xianli Wang, Mike Wotton, Alan Cantin, and Mike Flannigan
#' @seealso \code{\link{fwi}}, \code{\link{hffmc}}
#' @references Wotton, B.M. 2009. A grass moisture model for the Canadian
#' Forest Fire Danger Rating System. In: Proceedings 8th Fire and Forest
#' Meteorology Symposium, Kalispell, MT Oct 13-15, 2009. Paper 3-2.
#' \url{https://ams.confex.com/ams/pdfpapers/155930.pdf}
#'
#' Van Wagner, C.E. 1977. A method of computing fine fuel moisture content
#' throughout the diurnal cycle. Environment Canada, Canadian Forestry Service,
#' Petawawa Forest Experiment Station, Chalk River, Ontario. Information Report
#' PS-X-69. \url{https://cfs.nrcan.gc.ca/pubwarehouse/pdfs/25591.pdf}
#' @keywords methods
#' @importFrom data.table data.table
#' @export gfmc
#' @examples
#'
#' library(cffdrs)
#' # load the test data
#' data("test_gfmc")
#' # show the data format:
#' head(test_gfmc)
#' #     yr mon day hr temp   rh   ws prec  isol
#' # 1 2006   5  17 10 15.8 54.6  5.0    0 0.340
#' # 2 2006   5  17 11 16.3 52.9  5.0    0 0.380
#' # 3 2006   5  17 12 18.8 45.1  5.0    0 0.626
#' # 4 2006   5  17 13 20.4 40.8  9.5    0 0.656
#' # 5 2006   5  17 14 20.1 41.7  8.7    0 0.657
#' # 6 2006   5  17 15 18.6 45.8 13.5    0 0.629
#' # (1) gfmc default:
#' # Re-order the data by year, month, day, and hour:
#' dat <- test_gfmc[with(test_gfmc, order(yr, mon, day, hr)), ]
#' # Because the test data has 24 hours input variables
#' # it is possible to calculate the hourly GFMC continuously
#' # through multiple days(with the default initial GFMCold=85):
#' dat$gfmc_default <- gfmc(dat,out="GFMC")
#' # two variables will be added to the input, GFMC and MC
#' head(dat)
#' # (2) For multiple weather stations:
#' # One time step (1 hour) with default initial value:
#' foo <- gfmc(dat, batch = FALSE)
#' # Chronological hourly GFMC with only one initial
#' # value (GFMCold=85), but multiple weather stations.
#' # Note: data is ordered by date/time and the station id. Subset
#' # the data by keeping only the first 10 hours of observations
#' # each day:
#' dat1 <- subset(dat, hr %in% c(0:9))
#' # assuming observations were from the same day but with
#' # 9 different weather stations:
#' dat1$day <- NULL
#' dat1 <- dat1[with(dat1, order(yr, mon, hr)), ]
#' dat1$id <- rep(1:8, nrow(dat1) / 8)
#' # check the data:
#' head(dat1)
#' # Calculate GFMC for multiple stations:
#' dat1$gfmc01 <- gfmc(dat1, batch = TRUE)
#' # We can provide multiple initial GFMC (GFMCold) as a vector:
#' dat1$gfmc02 <- gfmc(
#'   dat1,
#'   GFMCold = sample(70:100, 8, replace = TRUE),
#'   batch = TRUE
#' )
#' # (3)output argument
#' ## include all inputs and outputs:
#' dat0 <- dat[with(dat, order(yr, mon, day, hr)), ]
#' foo <- gfmc(dat, out = "ALL")
#' ## subhourly time step:
#' gfmc(dat0, time.step = 1.5)
#'
#' @export gfmc

gfmc <- function(
    input,
    GFMCold = 85,
    batch = TRUE,
    time.step = 1,
    roFL = 0.3,
    out = "GFMCandMC") {
  # show warnings when inputs are missing
  required_cols <- data.table(
    full = c(
      "temperature", "precipitation", "wind speed", "relative humidity",
      "insolation"
    ),
    short = c("temp", "prec", "ws", "rh", "isol")
  )

  if (nrow(required_cols[-which(required_cols$short %in% names(input))]) > 0) {
    stop(paste(
      required_cols[-which(required_cols$short %in% names(input)), "full"],
      collapse = " , "
    ), " is missing!")
  }

  # check for issues with batching the function
  if (batch) {
    if (!is.null(input$id)) {
      n <- length(unique(input$id))
      if (length(unique(input$id)) != n) {
        stop(paste0(
          "Multiple stations have to start and end at the same dates/time,",
          " and input data must be sorted by date/time and id"
        ))
      }
    } else {
      n <- 1
    }
  } else {
    n <- length(input$temp)
  }

  if (length(input$temp) %% n != 0) {
    warning("Input data do not match with number of weather stations")
  }

  if (length(GFMCold) != n & length(GFMCold) == 1) {
    warning("One GFMCold value for multiple weather stations")
    GFMCold <- rep(GFMCold, n)
  }

  if (length(GFMCold) != n & length(GFMCold) > 1) {
    stop("Number of GFMCold doesn't match number of wx stations")
  }
  validOutTypes <- c("GFMCandMC", "MC", "GFMC", "ALL")
  if (!(out %in% validOutTypes)) {
    stop(paste("'", out, "' is an invalid 'out' type.", sep = ""))
  }

  # get the length of the data stream
  n0 <- length(input$temp) %/% n
  GFMC <- NULL
  MC <- NULL
  # iterate through timesteps
  for (i in 1:n0) {
    # k is the data for all stations by time step
    k <- (n * (i - 1) + 1):(n * i)

    MC <- grass_fuel_moisture(
      temp = input$temp[k],
      rh = input$rh[k],
      ws = input$ws[k],
      prec = input$prec[k],
      isol = input$isol[k],
      GFMCold = GFMCold,
      time.step = time.step,
      roFL = roFL
    )
    GFMC <- grass_fuel_moisture_code(MC)

    # Reset vars
    GFMCold <- GFMC
    MCold <- MC
    GFMC_out <- if(exists("GFMC_out")) {c(GFMC_out, GFMC)} else {GFMC}
    MC_out <- if(exists("MC_out")){ c(MC_out, MC)} else {MC}
  }

  # Return requested 'out' type
  if (out == "ALL") {
    return(cbind(input, data.frame(GFMC = GFMC_out, MC = MC_out)))
  } else if (out == "GFMC") {
    return(data.frame(GFMC = GFMC_out))
  } else if (out == "MC") {
    return(data.frame(MC = MC_out))
  } else { # GFMCandMC
    return(data.frame(GFMC = GFMC_out, MC = MC_out))
  }
}
