source('~/Desktop/PROJECTS/Humedica/CODE/functions_Intern.R')

# reading in the data to import PRESCRIPTION
rx_presc.data <- read.csv(file="~/Desktop/PROJECTS/HUMEDICA/data/rx_presc.csv", 
              stringsAsFactors=F, na.strings ="NA")
names(rx_presc.data) <- tolower(names(rx_presc.data))
dim(rx_presc.data) # 1040001 19

if (class(rx_presc.data$rxdate) != "Date") {
  print("Formatting the rxdate in R format. Check the raw format: m-d-Y")
  rx_presc.data$rxdate_mod <- as.Date(rx_presc.data$rxdate, "%m-%d-%Y")
}

# We get an error when formatting some dates so we take them out
errant.Dates <- rx_presc.data[nchar(rx_presc.data$rxdate)>10,]
dim(errant.Dates) # 73 19

# We want to make sure that the drug codes are not more than 11 characters in length
moreThan_11 <- rx_presc.data[nchar(rx_presc.data$ndc)>11,]
dim(moreThan_11) # 40 19

# We take out those values
# So we want only those patients that are not in either of the two categories
rx_presc.Filter <- rx_presc.data[(nchar(rx_presc.data$ndc)<=11) & (nchar(rx_presc.data$rxdate)<=10),]
dim(rx_presc.Filter) # 1039888      20
length(unique(rx_presc.Filter$ptid)) # 48130

# Now we can change the dates
if (class(rx_presc.Filter$rxdate) != "Date") {
  print("Formatting the rxdate in R format. Check the raw format: m-d-Y")
  rx_presc.Filter$rxdate_mod <- as.Date(rx_presc.Filter$rxdate, "%m-%d-%Y")
}

# We select only those observations from a year prior to index date so we merge it with studypop
temp <- read.csv(file="~/Desktop/PROJECTS/HUMEDICA/CODE/PROCESSED_TABLES/studypop.csv", stringsAsFactors=FALSE, 
                          colClasses=c("dmt_dt"="Date", "index_dt"="Date", "dmt_0"="character", "ptid"="character"), na.strings ="NA")
dim(temp) # 23302

reduced.pop <- subset(temp, select = c(ptid, index_dt))
sanity.check(temp, reduced.pop)

rx_presc.pop <- merge(reduced.pop, rx_presc.Filter, by = "ptid", all.x = TRUE)
dim(rx_presc.pop) # 475881     21
length(unique(rx_presc.pop$ptid)) # 23302

# We have to select only those that are in 1 year pre-index period
rx_presc.pop$dateDiff <- rx_presc.pop$index_dt - rx_presc.pop$rxdate_mod
rx_presc.pop <- rx_presc.pop[order(-rx_presc.pop$dateDiff),]
rx_presc.pop <- rx_presc.pop[(rx_presc.pop$dateDiff >= 0 & rx_presc.pop$dateDiff < 365), ]

dim(rx_presc.pop) # 58728 22
length(unique(rx_presc.pop$ptid)) # 11639

# remove unncessary variables
rx_presc.pop$dateDiff <- rx_presc.pop$index_dt <- NULL

# Let's keep a copy of this file before preparing ontology 
write.csv(rx_presc.pop, file = "~/Desktop/PROJECTS/HUMEDICA/CODE/PROCESSED_TABLES/Rx_presc_pop.csv", row.names=FALSE )


