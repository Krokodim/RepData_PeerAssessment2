library(dplyr)
library(lubridate)
library(ggplot2)


ex_log <- function (s) {
  s <- paste(now(), s, sep = ">> ")
  message(s)
}

ex_log("Start")

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


ex_log("Read started")


if (!exists("dt.raw")) {
  dt.raw <- read.table(
    file="repdata_data_StormData.csv.bz2",
    head=TRUE, sep=",",       comment.char = "",
    row.names = "REFNUM",     colClasses = read.classes,
    stringsAsFactors=FALSE,   na.strings = c(" ", ""),
    nrows = 10^6
  )
}
dt <- dt.raw

ex_log("Read finished")

# set the column names
colnames(dt) <- c(
  "date",          "event.type",       "fatalities",    "injuries", 
  "prop.damage",   "prop.damage.exp",  "crop.damage",   "crop.damage.exp"
)

# convert BGN_date
dt$date <- mdy_hms(dt$date)

# convert event types
event.groups = list(
  c("Avalanches",
    "AVALANCE","AVALANCHE","LANDSLIDE","LANDSLIDES","MUDSLIDE"),
  
  c("Cold weather",
    "COLD","COLD AND SNOW","COLD TEMPERATURE","COLD WAVE","COLD WEATHER",
    "EXTENDED COLD","EXTREME COLD","FOG AND COLD TEMPERATURES","FREEZE",
    "HYPOTHERMIA","HYPOTHERMIA/EXPOSURE","LOW TEMPERATURE","RECORD COLD",
    "SNOW/ BITTER COLD","UNSEASONABLY COLD","WINTER WEATHER",
    "WINTER WEATHER/MIX","WINTRY MIX"),
  
  c("Fog",
    "DENSE FOG","FOG"),
  
  c("Hot weather",
    "DROUGHT/EXCESSIVE HEAT","EXCESSIVE HEAT","EXTREME HEAT","HEAT","HEAT WAVE",
    "HEAT WAVE DROUGHT","HEAT WAVES","HYPERTHERMIA/EXPOSURE","RECORD HEAT",
    "RECORD/EXCESSIVE HEAT","RECORD/HEAT","UNSEASONABLY WARM",
    "UNSEASONABLY WARM AND DRY"),
  
  c("Winds & Tornadoes",
    "COASTAL STORM","COASTALSTORM","COLD/WIND CHILL","COLD/WINDS",
    "DRY MICROBURST","DUST DEVIL","DUST STORM","EXTREME COLD/WIND CHILL",
    "EXTREME WINDCHILL","GUSTY WIND","GUSTY WINDS","HEAVY SURF AND WIND",
    "HIGH WIND","HIGH WIND AND SEAS","HIGH WIND/SEAS","HIGH WINDS","HURRICANE",
    "HURRICANE ERIN","HURRICANE FELIX","HURRICANE OPAL","HURRICANE OPAL/HIGH WINDS",
    "HURRICANE/TYPHOON","ICE STORM","MARINE HIGH WIND","MARINE STRONG WIND",
    "MARINE THUNDERSTORM WIND","MARINE TSTM WIND","RAIN/WIND","STORM SURGE",
    "STORM SURGE/TIDE","STRONG WIND","STRONG WINDS","THUNDERSTORM","THUNDERSTORM WIND",
    "THUNDERSTORM WIND (G40)","THUNDERSTORM WIND G52","THUNDERSTORM WINDS",
    "THUNDERTORM WINDS","TORNADO","TORNADOES, TSTM WIND, HAIL","TROPICAL STORM",
    "TROPICAL STORM GORDON","TSTM WIND","TSTM WIND (G35)","TSTM WIND/HAIL",
    "WATERSPOUT/TORNADO","WHIRLWIND","WIND","WIND STORM","WINDS","WINDS & TORNADOES",
    "WINTER STORM","WINTER STORM HIGH WINDS","WINTER STORMS"),
  
  c("On-water accidents",
    "DROWNING","HEAVY SEAS","HEAVY SURF","HEAVY SURF/HIGH SURF","HIGH SURF",
    "HIGH SWELLS","HIGH WAVES","MARINE ACCIDENT","MARINE MISHAP","RIP CURRENT",
    "RIP CURRENTS","RIP CURRENTS/HEAVY SURF","ROUGH SEAS","ROUGH SURF"),
  
  c("Precip",
    "BLIZZARD","BLOWING SNOW","EXCESSIVE RAINFALL","FALLING SNOW/ICE","FREEZING RAIN",
    "FREEZING RAIN/SNOW","HAIL","HEAVY RAIN","HEAVY SNOW","HEAVY SNOW AND HIGH WINDS",
    "HIGH WINDS/SNOW","LIGHT SNOW","MIXED PRECIP","RAIN/SNOW","SLEET","SNOW",
    "SNOW AND ICE","SNOW SQUALL","SNOW SQUALLS","THUNDERSNOW"),
  
  c("High waters",
    "COASTAL FLOOD","COASTAL FLOODING","FLASH FLOOD","FLASH FLOOD/FLOOD","FLASH FLOODING",
    "FLASH FLOODING/FLOOD","FLASH FLOODS","FLOOD","FLOOD & HEAVY RAIN","FLOOD/FLASH FLOOD",
    "FLOOD/RIVER FLOOD","FLOODING","HIGH SEAS","HIGH WATER","MINOR FLOODING",
    "RAPIDLY RISING WATER","RIVER FLOOD","RIVER FLOODING","URBAN AND SMALL STREAM FLOODIN",
    "URBAN/SML STREAM FLD","WATERSPOUT"),
  
  c("Lightnings",
    "LIGHTNING","LIGHTNING."),
  
  c("Tsunami",
    "TSUNAMI"),
  
  c("Fire",
    "WILD FIRES","WILD/FOREST FIRE","WILDFIRE"),
  
  c("Ice & frost",
    "BLACK ICE","FREEZING DRIZZLE","FREEZING SPRAY","FROST","GLAZE","ICE",
    "ICE ON ROAD","ICY ROADS")
)

#paste(xx[grepl("fog",xx, ignore.case=TRUE)], sep=", ", collapse='", "')


for(i in 1:length(event.groups)){
  
  try(dt[toupper(dt$event.type) %in% toupper(event.groups[[i]]),]$event.type <- event.groups[[i]][1])

#   pattern <- paste(toupper(event.groups[[i]]), sep="|")
#   replacement <- event.groups[[i]][1]
#   dt$event.type <- sub(
#     , toupper(event.groups[[i]][1]),
#     dt$event.type)
}


# analyse fatalities
t1 <- dt %>% group_by(event.type) %>% 
  summarise(
    count = n(),
    fatalities.total = sum(fatalities),
    fatalities.mean = round(mean(fatalities),2),
    fatalities.max = max(fatalities)
  ) %>%
  filter(fatalities.total > 0) %>%
  arrange(desc(fatalities.total))

xx <- sort(unique(t1$event.type))
xx



summary(t1)


ex_log("Total finish")
