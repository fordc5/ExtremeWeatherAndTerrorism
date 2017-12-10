


terrorismOriginalData <- read.csv(file="TerrorismMaster.csv", header=TRUE, sep=",")
head(terrorismOriginalData)



library(stringr)
terrorismData <- terrorismOriginalData %>%
  unite(date1, iyear,imonth,iday, sep="-") %>%
  mutate(dateLub = ymd(date1)) %>%
  filter(!is.na(dateLub)) %>%
  mutate(isAttack = as.integer(!is.na(eventid))) %>%
  mutate(countryParsed = toupper(country_txt)) %>%
  group_by(country_txt) %>%
  mutate(totalPerCountry = n()) %>%
  arrange(dateLub) 
head(terrorismData)
dim(terrorismData)


weatherOriginalData <- read.csv(file="GlobalLandTemperaturesByCity.csv", header=TRUE, sep=",")
head(weatherOriginalData)


weatherData <- weatherOriginalData %>%
  mutate(dateLub = ydm(dt)) %>%
  filter(!is.na(dateLub)) %>%
  filter(dateLub >= as.Date("1970-01-01")) %>%
  filter(!is.na(AverageTemperature)) %>%
  mutate(Country = toupper(Country))


dim(weatherData)
head(weatherData, 1000)


mergedMasterData <- left_join(weatherData, terrorismData, by=c("dateLub", "Country" = "countryParsed")) %>%
  mutate(isAttack = as.integer(!(is.na(isAttack)))) %>%
  arrange(dateLub)

mergedMasterDataSelectedCols <- mergedMasterData[,c("dateLub", "Country", "City", "city", "AverageTemperature", "Latitude", "Longitude", "summary", "nkill", "isAttack", "eventid","totalPerCountry")] 

head(mergedMasterDataSelectedCols, 100)
dim(mergedMasterDataSelectedCols)



##NN data aggregating
nnData <- mergedMasterDataSelectedCols %>%
  #Get country code
  transform(countryCode = as.numeric(factor(Country))) %>%
  #Get histDayAvg
  transform(year = year(ymd(dateLub))) %>%
  transform(month = month(ymd(dateLub))) %>%
  transform(day = day(ymd(dateLub))) %>%
  group_by_(.dots=c("countryCode","month","day")) %>% 
  mutate(histDayAvg = mean(AverageTemperature))


#number attacks per period function
numTrBw <- function(frame) {
  
  frame <- frame %>%
    filter(isAttack) %>%
    filter(!is.na(city))
  
  
  if (FALSE){
    print(frame)
    c <- vector()
    for(i in 1:nrow(frame)) {
      print(i)
      row <- frame[i,]
      # do stuff with row
      code <- row$countryCode
      dateFuture <- row$dateLub
      datePast <- row$monthBefore
      
      temp <- frame %>% filter(countryCode == code)
      
      total <- 0
      while(year(ymd(dateFuture)) != year(ymd(datePast)) | month(ymd(dateFuture)) != month(ymd(datePast)) | day(ymd(dateFuture)) != day(ymd(datePast))) {
        #print(1)
        prevDay <- dateFuture - days(1)
        temp <- temp %>% filter(dateLub == prevDay) %>% slice(1)
        print(row)
        if(temp$isAttack) {
          #print(2)
          total <- total + 1
        }
        #print(3)
        dateFuture <- prevDay
      }
      #print(4)
      c <- append(c, total)
      
    }
    print(frame %>% mutate(hellloe = c))
  }
}


nnData <- nnData %>%
  #Attacks in one month prior
  #group_by(countryCode) %>%
  mutate(monthBefore = dateLub - months(1))



nnData <- nnData %>%
  filter(isAttack == 1) %>%
  #filter(!is.na(city)) %>%
  group_by_(.dots=c("countryCode","dateLub")) %>% 
  mutate(attacksPriorYear = n())

nnData <- nnData[,c("countryCode", "histDayAvg", "AverageTemperature","isAttack", "attacksPriorYear")]


dim(nnData)
head(nnData,200)





# Random sampling
samplesize <- 0.60 * nrow(mergedMasterDataSelectedCols)
set.seed(47)
index <- sample(seq_len(nrow(mergedMasterDataSelectedCols)), size = samplesize)

# Create training and test set
dataTrain <- mergedMasterDataSelectedCols[index,]
dataTest <- mergedMasterDataSelectedCols[-index,]

# Scale data for neural network
maxScale <- apply(mergedMasterDataSelectedCols, 2, max)
minScale <- apply(mergedMasterDataSelectedCols, 2, min)
scaledData <- as.data.frame(scale(mergedMasterDataSelectedCols, center = minScale, scale = maxScale - minScale))







#Function that convertes a vector of Lats or Longs of the 
#format string ("47.47N") to 47.47 as numeric

changeLatLong <- function(x) {
  res <- c()
  for (e in x) {
    charV <- strsplit(e, "")
    dir <- tail(charV[[1]], n=1)
    if (!identical(dir, character(0))) {
      charV <- head(charV[[1]], -1)
      res <- c(res, as.numeric(paste(charV, collapse="")))
    } else {
      res <- c(NA, res)
    }
  }
  return(res)
}





#Function to convert vectors of Longitude and Latitude to the appropriate State


# The single argument to this function, pointsDF, is a data.frame in which:
#   - column 1 contains the longitude in degrees (negative in the US)
#   - column 2 contains the latitude in degrees

latlong2state <- function(pointsDF) {
# Prepare SpatialPolygons object with one SpatialPolygon
# per state (plus DC, minus HI & AK)
states <- map('state', fill=TRUE, col="transparent", plot=FALSE)
IDs <- sapply(strsplit(states$names, ":"), function(x) x[1])
states_sp <- map2SpatialPolygons(states, IDs=IDs,
proj4string=CRS("+proj=longlat +datum=WGS84"))

# Convert pointsDF to a SpatialPoints object 
pointsSP <- SpatialPoints(pointsDF, 
proj4string=CRS("+proj=longlat +datum=WGS84"))

# Use 'over' to get _indices_ of the Polygons object containing each point 
indices <- over(pointsSP, states_sp)

# Return the state names of the Polygons object containing each point
stateNames <- sapply(states_sp@polygons, function(x) x@ID)
stateNames[indices]
}



#Another attempt at getting state using parallel processing

library(foreach)
library(doParallel)

getState <- function(lat, long) {

#setup parallel backend to use many processors
cores = detectCores()
cl <- makeCluster(cores[1]-1) #not to overload computer
registerDoParallel(cl)

finalMatrix <- foreach(i=1:length(lat)) %dopar% {
newState <- revgeocode(c(long[i], lat[i]), output = "more")$administrative_area_level_1
result <- append(result, newState)
}
#stop cluster
stopCluster(cl)
}

getStates <- function(lat, long) {
result <- c()
for (i in 1:10000) {
result <- append(result, revgeocode(c(-100.5, 45), output = "more")$administrative_area_level_1)
}
return(result)
}


visualizationsAttacks <- usaTerrorismData %>% 
  filter(provstate != "Puerto Rico") %>% 
  filter(provstate != "Alaska") %>% 
  filter(provstate != "Hawaii") %>% filter(longitude < 0) %>%
  filter(!is.na(nkill)) 


g <- list(
  scope = 'usa',
  projection = list(type = 'albers usa'),
  showland = TRUE,
  landcolor = toRGB("gray95"),
  subunitcolor = toRGB("gray85"),
  countrycolor = toRGB("gray85"),
  countrywidth = 0.5,
  subunitwidth = 0.5
)

p <- plot_geo(visualizationsAttacks, lat = ~latitude, lon = ~longitude) %>%
  add_markers(
    text = ~paste(city, provstate, paste("Attack type:", attacktype1_txt), sep = "<br />"), symbol = I("circle"), size = I(2), hoverinfo = "text"
  )%>%
  layout(
    title = 'Attacks', geo = g
  )

p
