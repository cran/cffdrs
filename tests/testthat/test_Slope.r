test_that("Slope", {
  fctSlope <- function(FUELTYPE, FFMC, BUI, WS, WAZ, GS, SAZ, FMC, SFC, PC, PDF, CC, CBH, ISI) {
    return(as.data.table(slope_adjustment(FUELTYPE, FFMC, BUI, WS, WAZ, GS, SAZ, FMC, SFC, PC, PDF, CC, CBH, ISI)))
  }
  checkData("Slope",
    fctSlope,
    list(
      data.table(FUELTYPE = FUELTYPE),
      data.table(FFMC = FFMC),
      data.table(BUI = BUI),
      data.table(WS = WS),
      data.table(WAZ = WAZ),
      data.table(GS = GS),
      data.table(SAZ = SAZ),
      data.table(FMC = FMC),
      data.table(SFC = SFC),
      data.table(PC = PC),
      data.table(PDF = PDF),
      data.table(CC = CC),
      data.table(CBH = CBH),
      data.table(ISI = ISI)
    ),
    split_args = TRUE,
    with_input = TRUE
  )
})
