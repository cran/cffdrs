test_that("CriticalSurfaceIntensity", {
  fctCSI <- function(FUELTYPE, FMC, SFC, ROS, CBH, option)
  {
    return(critical_surface_intensity(FMC, CBH))
  }
  checkData('CriticalSurfaceIntensity',
            fctCSI,
            list(data.table(FUELTYPE=FUELTYPE),
                 data.table(FMC=FMC),
                 data.table(SFC=SFC),
                 data.table(ROS=ROS),
                 data.table(CBH=CBH),
                 data.table(option=c("CSI"))))
})
