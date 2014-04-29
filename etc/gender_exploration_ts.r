setwd("C:\\Users\\William\\Documents\\William's Files\\R Tutorials\\Shiny Server")

library(lubridate)
library(ggplot2)
library(scales)
library(reshape)
library(animation)

# Define a function to get the aggregate data over a particular date

# ------------------------------------------------------------------------------

# getGenderDF
# 
# Date Modified:  2013-12-29
# I/O :           Dataframe + Date -> Dataframe
# 
# Description:    Takes the Cognos data and a specific date as input and returns
#                 a dataframe containing the aggregrate gender information.

# ------------------------------------------------------------------------------

getGenderDF <- function(data, in.date) {
  
  # Clean and aggregate
  data.sub <- subset(data, Program != "FIRST MAJOR" & Date == in.date,
                     select=c("Program", "Gender", "FACULTY"))
  data.sub.agg <-aggregate(FACULTY ~ Program + Gender, data=data.sub, FUN=sum)
  names(data.sub.agg)[3] <- "n"
  
  # Create an index
  data.msub <- subset(data, Program != "FIRST MAJOR" & Date == in.date,
                      select=c("Program", "AHS","ARTS","CFM", "ENG","MATH",
                               "REN", "SCI", "SE", "ENV", "ID.S"))
  data.msub.agg <-aggregate(. ~ Program, data=data.msub, FUN=sum)
  idx.melt <- melt(data.msub.agg, id=c("Program"))
  idx <- subset(idx.melt, value > 0, select=-value)
  names(idx)[2] <- "Faculty"
  
  # Generate the male and female reference databases and merge
  male.data <- subset(merge(data.sub.agg, idx), 
                      Gender == "Male", select=-Gender)
  female.data <- subset(merge(data.sub.agg, idx), 
                        Gender == "Female", select=-Gender)
  comb.data <- merge(male.data, female.data, 
                     by=c("Program","Faculty"), all=T)
  comb.data[is.na(comb.data)] <- 0
  
  # Get the percent female, total count
  comb.data$percent.female <- comb.data$n.y/(comb.data$n.x+comb.data$n.y)
  comb.data$n <- comb.data$n.x + comb.data$n.y
  
  # Note: PSYCH is considered an ART and SCI major; we will keep it as SCI
  comb.data <- subset(comb.data, !(Program == "PSYCH" & Faculty == "SCI"))
  
  # Note: GEOG is considered an ENV and SCI major; we will keep it as ENV
  comb.data <- subset(comb.data, !(Program == "GEOG" & Faculty == "ENV"))  
  
  # Note: GEOG is considered an SE and ID.S major; we will keep it as SE
  comb.data <- subset(comb.data, !(Program == "SE" & Faculty == "SE"))  
  
  
  # Reorder and add the date back
  comb.data$Program <- reorder(comb.data$Program, comb.data$percent.female)
  comb.data$Date <- in.date
  
  # Return the data frame of the combined data
  return(comb.data)
  
}

# Import and clean up the input data
cognos.data <- read.csv("cognos_data_gender.csv")
cognos.data$RDate <- paste0(cognos.data$Date,"-01")
cognos.data$Date <- as.Date(cognos.data$RDate, format="%b-%y-%d")

# Test cases
septdata <- getGenderDF(cognos.data, as.Date("2013-09-01"))
maydata <- getGenderDF(cognos.data, as.Date("2013-05-01"))
rm(septdata, maydata)

# Loop over all dates and merge into one big data frame
date.rng <- rev(unique(cognos.data$Date))
for (i in 1:length(date.rng)) {
  if (i == 1) {
    temp <- getGenderDF(cognos.data, date.rng[1])
    if (length(unique(temp$Program)) < 20) {
      next
    } else {
      gender.data <- temp
    }
  } else {
    temp <- getGenderDF(cognos.data, date.rng[i])
    if (length(unique(temp$Program)) < 20) {
      next
    } else {
      gender.data <- rbind(gender.data,temp)
    }
  }
}
rm(i,temp)

# Get a subset for testing
gender.data.sub <- subset(gender.data, Date == "2013-09-01")
gender.data.sub$Program <- reorder(gender.data.sub$Program, 
                                   gender.data.sub$percent.female)

# Visualize with ggplot2 without gradients
ggplot(data=gender.data.sub, aes(x=Program, y=percent.female, fill=Faculty)) + 
  geom_bar(stat="identity") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1))

# Save a movie
date.rng.sub <- unique(gender.data$Date)
saveMovie({
  for (i in 1:length(date.rng.sub)) {
    gender.data.sub <- subset(gender.data, Date == date.rng.sub[i])
    gender.data.sub$Program <- reorder(gender.data.sub$Program, 
                                       gender.data.sub$percent.female)
    
    print(ggplot(data=gender.data.sub, aes(x=Program, y=percent.female, fill=Faculty)) + 
            geom_bar(stat="identity") +
            theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
            ggtitle(date.rng.sub[i]))
  }
}, interval = 0.5, movie.name = "ggplot2-gender.gif", 
   ani.width = 1800, ani.height = 600)
rm(i)

# Examine the gender mixture progress over time (STEM)
for (i in 1:length(date.rng.sub)) {
  gender.data.sub <- subset(gender.data, Date == date.rng.sub[i])
  gender.data.sub <- gender.data.sub[order(gender.data.sub$percent.female),]
                                     
  df.row <- data.frame (Date = date.rng.sub[i],
                        SCI.mix = 
                          mean(tail(which(gender.data.sub$Faculty == "SCI"),3))/ 
                          length(gender.data.sub$Faculty),
                        ENG.mix = 
                          mean(tail(which(gender.data.sub$Faculty == "ENG"),3))/ 
                          length(gender.data.sub$Faculty),
                        MATH.mix = 
                          mean(tail(which(gender.data.sub$Faculty == "MATH"),3))/ 
                          length(gender.data.sub$Faculty))
  
  if (i==1) {
    mix.data <- df.row
  } else {
    mix.data <- rbind(mix.data, df.row)
  }
}
rm(i, df.row)

# Plot the mixture data
mix.melt.data <- melt(mix.data, id="Date")
xyplot(value ~ Date | variable,
       data = mix.melt.data, 
       type = c("p","g","smooth","spline"),
       panel = function(x, y, col, ...) {
         panel.xyplot(x, y, ...)
         panel.loess(x, y, col = "red")
         panel.spline(x, y, col = "dark green")
       })

# Run a regression
mix.melt.data$Idx <- 1:dim(mix.melt.data)[1]
summary(lm(value ~ Idx * variable, data=mix.melt.data))
