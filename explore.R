library(dplyr)
library(lubridate)
library(ggplot2)

# setup column classes to speed up reading (NULLs won't be read)
read.classes <- c(
  STATE__    = "NULL",      BGN_DATE   = "character", BGN_TIME   = "NULL",      
  TIME_ZONE  = "NULL",      COUNTY     = "NULL",      COUNTYNAME = "NULL",      
  STATE      = "NULL",      EVTYPE     = "character", BGN_RANGE  = "NULL",      
  BGN_AZI    = "NULL",      BGN_LOCATI = "NULL",      END_DATE   = "NULL",      
  END_TIME   = "NULL",      COUNTY_END = "NULL",      COUNTYENDN = "NULL",      
  END_RANGE  = "NULL",      END_AZI    = "NULL",      END_LOCATI = "NULL",      
  LENGTH     = "NULL",      WIDTH      = "NULL",      F          = "NULL",      
  MAG        = "NULL",      FATALITIES = "numeric",   INJURIES   = "numeric",
  PROPDMG    = "numeric",   PROPDMGEXP = "character", CROPDMG    = "numeric",
  CROPDMGEXP = "character", WFO        = "NULL",      STATEOFFIC = "NULL",      
  ZONENAMES  = "NULL",      LATITUDE   = "NULL",      LONGITUDE  = "NULL",      
  LATITUDE_E = "NULL",      LONGITUDE_ = "NULL",      REMARKS    = "NULL",      
  REFNUM     = "numeric"
)

system.time(
# read the raw data
dt <- read.table(
  file="repdata_data_StormData.csv.bz2",
  head=TRUE,
  stringsAsFactors=FALSE,
  sep=",",
  comment.char = "",
  row.names = "REFNUM",
  colClasses = read.classes,
  na.strings = c(" ", ""),
  nrows = 10^6
)
)

# set the column names
colnames(dt) <- c(
    "date",          "event.type",       "fatalities",    "injuries", 
    "prop.damage",   "prop.damage.exp",  "crop.damage",   "crop.damage.exp"
  )

# convert BGN_date
dt$date <- mdy_hms(dt$date)

summary(dt$MAG)
