setwd('~/Projects/yelp_phoenix_academic_dataset/scripts/')

df_checkin <- read.table('yelp_checkin.tsv', sep = '\t', stringsAsFactors=F, header = T)
df_business <- read.csv('yelp_business.tsv', sep = '\t')

business <- merge(df_business, df_checkin, by = 'id_business', all.x= T, all.y = F)
# if a business didn't have a checkin in the data, impute zeros
business[is.na(business)] <- 0

require(plyr)
require(reshape2)
require(stringr)

extractWeekDay <- function(x){
  # extract week day from checkin info
  strsplit(x, '\\.')[[1]][2]  
}
extractHr <- function(x){
  # extract hour from checkin info  
  strsplit(x, '\\.')[[1]][1]  
}


checkinData <- melt(df_checkin, id.vars='id_business')
checkinData$variable <- str_replace(checkinData$variable,'X','')
checkinData$weekDay <- sapply(checkinData$variable, extractWeekDay) 
checkinData$hr <- sapply(checkinData$variable, extractHr) 
checkinData_byWeekDay <- ddply(.data = checkinData, .variables=c('id_business','weekDay'),
                               summarise,
                               numCheckins = sum(value))
checkinData_byWeekDay <- recast(checkinData_byWeekDay,
                                id_business ~ weekDay,fun.aggregate=sum)
weekdays <- c('sun','mon','tue','wed','thu','fri','sat')

names(checkinData_byWeekDay)[2:8] <- weekdays

weekDay.Hr <- ddply(.data = checkinData, 
                                  .variables=c('weekDay', 'hr'), 
                                  summarise,
                                  numCheckins = sum(value))


getCategory = function(df, categorylist){
  df$primaryCategory = NA  
  for (i in 1:length(categorylist)){
    df$primaryCategory[df[,categorylist[i]] == 1 & is.na(df$primaryCategory)] <- categorylist[i]
  }
  df$primaryCategory[is.na(df$primaryCategory)] <- "Other"
  df$primaryCategory
}

categories_primary <- c('Restaurants','Shopping','Beauty...Spas','Nightlife', 'Active.Life')

business_categories <- data.frame(business$id_business)
business_categories$primaryCategory <- getCategory(business, categories_primary)
names(business_categories) = c('id_business', 'primaryCategory')


weekDay.Hr.Cat <- ddply(.data = merge(checkinData,business_categories, by='id_business'), 
                    .variables=c('weekDay', 'hr', 'primaryCategory'), 
                    summarise,
                    numCheckins = sum(value))




require(ggplot2)
require(ggthemes)

### Variations in checkins over the course of the day, by weekday
ggplot(weekDay.Hr, aes(x = as.integer(hr), y = numCheckins)) +
  geom_line(aes(group = weekDay, color = weekDay)) + geom_point(aes(color = weekDay)) +
  xlab('Hours in the day') + ylab('Total Number of Checkins') +
  ggtitle('Checkins by day and hour') + theme_minimal()

weekDay.Hr.Cat <- weekDay.Hr.Cat[order(weekDay.Hr.Cat$weekDay),]

ggplot(weekDay.Hr.Cat, aes(x = as.integer(hr), y = numCheckins)) +
  geom_line(aes(group = as.factor( weekDay), color = weekDay)) + geom_point(aes(color =  weekDay)) +
  facet_grid(. ~ primaryCategory) +
  xlab('Hours in the day') + ylab('Total Number of Checkins') +
  ggtitle('Checkins by day and hour') + theme_minimal() + guides(fill = guide_legend(reverse = TRUE))




# use business_categories to merge categories to business


#business_melt <- melt(data = business, id.vars=names(business)[1:515])
#business_melt$variable <- str_replace(business_melt$variable,'X','')

#business_melt$weekDay <- sapply(business_melt$variable, extractWeekDay) 
#business_melt$hr <- sapply(business_melt$variable, extractHr)



#################################
temp <- melt(
  ddply(.data = merge(checkinData_byWeekDay, business_categories,by='id_business'),
              .variables= c('primaryCategory'),
              summarise,           
              sun = sum(sun),
              mon= sum(mon),
              tue= sum(tue),
              wed= sum(wed),
              thu= sum(thu),
              fri= sum(fri),
              sat= sum(sat) 
              )
)

ggplot(temp, aes(variable, value, fill = primaryCategory)) +
  geom_bar(stat = 'identity') +
  xlab('Day of the week') + ylab('Number of checkins') + ggtitle('Checkins by major category') +
  theme_minimal()
#################################

temp <- melt(
  ddply(.data = merge(checkinData_byWeekDay, business_categories,by='id_business'),
        .variables= c('primaryCategory'),
        summarise,           
        sun = sum(sun),
        mon= sum(mon),
        tue= sum(tue),
        wed= sum(wed),
        thu= sum(thu),
        fri= sum(fri),
        sat= sum(sat) 
  )
)
temp2 <- data.frame(colSums(checkinData_byWeekDay))
temp2$variable <- weekdays
names(temp2) <- c('tot','variable')

temp <- merge(temp,temp2,by='variable')
temp$Share <- with(temp, value/tot * 100)

ggplot(temp, aes(variable, Share, fill = primaryCategory)) + geom_bar(stat = 'identity') +
  xlab('Day of the week') + ylab('Number of checkins') + ggtitle('Checkins by major category') +
  theme_minimal()

########################################################

restaurant_list <- c('Buffets', 'Pizza', 'Fast.Food', 'Bars','Breakfast...Brunch','Steakhouses')

restaurant_categories <- business[business$Restaurants == 1,]
restaurant_categories$restaurantCategory <- getCategory(restaurant_categories, restaurant_list)
restaurant_categories <- restaurant_categories[restaurant_categories$restaurantCategory != 'Other',c('id_business','restaurantCategory')]


temp <- melt(
  ddply(.data = merge(checkinData_byWeekDay, restaurant_categories, by = 'id_business', all.x = F, all.y = F),
        .variables= c('restaurantCategory'),
        summarise,           
        sun = sum(sun),
        mon= sum(mon),
        tue= sum(tue),
        wed= sum(wed),
        thu= sum(thu),
        fri= sum(fri),
        sat= sum(sat) 
  )
)

ggplot(temp, aes(variable, value, fill = restaurantCategory)) +
  geom_bar(stat = 'identity') +
  xlab('Day of the week') + ylab('Number of checkins') + ggtitle('Checkins by major category') +
  theme_minimal()




###########################################
business_success <- business[, c('stars_business','review_count_business','id_business')]

temp <- merge(checkinData, business_success, by = 'id_business')
temp <- merge(temp, business_categories, by = 'id_business')


temp2 <- ddply(.data = temp, 
                           .variables = c('id_business','weekDay', 'stars_business', 'review_count_business', 'primaryCategory'),
                           summarise,
                           dayCheckins = sum(value)
             )

temp3 <- ddply(.data = temp, 
               .variables = c('weekDay','primaryCategory'),
               summarise,
               totCheckins = sum(value)
)


temp4 <- merge(temp2, temp3, by = c('weekDay','primaryCategory'))
temp4$contr_star <- with(temp4, dayCheckins / totCheckins * stars_business)
temp4$contr_rev <- with(temp4, dayCheckins / totCheckins * review_count_business)

temp5 <- ddply(.data = temp4, .variables = c('weekDay','primaryCategory'), summarise,
                    avgStars = sum(contr_star),
                    avgNumReviews = sum(contr_rev),
                    avgCheckins = mean(totCheckins)
               
                    )

ggplot(temp5, aes(weekDay, avgNumReviews)) + geom_point(aes(size = avgCheckins, color = avgStars))



ggplot(checkins_6, aes(as.integer(weekDay), avgStars, color = primaryCategory)) + 
  geom_point(aes(size = avgNumReviews)) + geom_line()
  theme_minimal()

ggplot(checkins_6, aes(avgNumReviews)) + geom_histogram()
df3_melt <- melt(data=df3, id.vars= c('name_business', 'lon_business', 'lat_business', 'weekDay', 'review_count_business', 'stars_business'))
df3_reshaped <- cast(data=df3_melt,formula=name_business + lon_business + lat_business + review_count_business + stars_business~weekDay, sum)

getRowMax <- function(row){
  normalized = row / sum(row)
  maxVal = max(normalized)
  maxDay = which.max(matrix(normalized)) - 1
  if(maxVal >0.33){
    result = maxDay}
  else{
    result = -1
  }
}

df3_reshaped$topWeekDay <- apply(df3_reshaped[,5:11], 1, getRowMax)
df3_reshaped$totalCheckins <- apply(df3_reshaped[,5:11], 1, sum)

ggplot(df3_reshaped[df3_reshaped$topWeekDay!=-1 ,], aes(lat_business, lon_business, colour = as.factor(topWeekDay))) +
  geom_point(alpha = 0.3, aes(size = review_count_business)) + 
  theme_minimal()

ggplot(df3_reshaped, aes(review_count_business, totalCheckins)) +
  geom_point(alpha = 0.3, aes(size = review_count_business)) + 
  theme_minimal()


ggplot(checkins_collapsed3[checkins_collapsed3$primaryCategory == 'Restaurants',], aes(x = as.integer(hr), y = numCheckins)) +
  geom_line(aes(group = weekDay, color = weekDay)) +
  theme_minimal()



# Chart: hours in day X weekdays  ~ number of checkins
  #- by category
  #- by secondary category

# Chart: week day X avg star  ~ size: average review count
  #- by category
  #- by secondary category

# Chart: Stacked bar of types of places over course of week

# word cloud of associated terms with each of hte week days in review text

# bubble chart: bubbles represent each categories. x = week day. y = number of checkins (avg). size = number of reviews (avg)

# bar chart: average number of words in review X week day

# deep dive: fast food, pizza, deli, brunch, steakhouses

# reception of reviews by weekday. average votes.

# cluster analysis using features [monday, tuesday, wednesday, thursday, fri, saturday, sunday, weekday, weekend, morning, night afternoon, evening] using review X business for lonogitude and latitude.

# do users with multiple reviews write on the same day? which day?

sun_df <- colMeans(read.csv(file = '../docStat_Sunday.csv'))

mon_df <- colMeans(read.csv(file = '../docStat_Monday.csv'))
tues_df <- colMeans(read.csv(file = '../docStat_Tuesday.csv'))
wed_df <- colMeans(read.csv(file = '../docStat_Wednesday.csv'))

thurs_df <- colMeans(read.csv(file = '../docStat_Thursday.csv'))
fri_df <- colMeans(read.csv(file = '../docStat_Friday.csv'))
sat_df <- colMeans(read.csv(file = '../docStat_Saturday.csv'))

weekdays <- c('sun','mon','tue','wed','thu','fri','sat')

docStats <- data.frame(rbind(sun_df, mon_df, tues_df, wed_df, thurs_df, fri_df, sat_df))
docStats$day <- factor(weekdays)

require(ggplot2)

ggplot(docStats, aes(x = day, y = Number.of.Words)) + geom_bar()



reviews <- read.csv('yelp_review.tsv', sep = '\t')

require(plyr)

unique.users <- ddply(.data = reviews, .variables = c('id_user','date_weekday'), summarise,
                      numReviews = NROW)

require(data.table)


key(reviews)
dt <- data.table(reviews, key=c('id_user', 'date_weekday')

                 
unique_users <- dt[,list(ct=NROW(id_review)), by=c('id_user','date_weekday')]


require(reshape2)


users_melt <- melt(data=unique_users, id.vars=c('id_user','date_weekday'))
users_recast <- cast(users_melt, id_user~date_weekday, sum)
weekdays <- c('sun','mon','tue','wed','thu','fri','sat')

names(users_recast)[2:8] <- weekdays

user_df <- read.csv('yelp_user.tsv', sep = '\t')

users_recast$total <- with(users_recast, sun + mon + tue + wed + thu + fri + sat)

users_merged <- merge(user_df, users_recast, by= 'id_user')

for(day in weekdays){
  users_recast[,day] <- users_recast[,day]/users_recast$total
}

rowMax <- function(row){
  maxVal = max(row)
}

colOfMax <- function(row){
  loc <- which.max(matrix(row))
  print(loc)
  maxCol = weekdays[loc]
}

users_recast$conc <- apply(users_recast[,weekdays], MARGIN=1, rowMax)
users_recast$primaryDay <- apply(users_recast[,weekdays], MARGIN=1, colOfMax)



users_recast_merged <- merge(users_recast, user_df, by = 'id_user')

multUserusers <- users_recast_merged[users_recast_merged$total >7,]


ggplot(multUserusers, aes(x = conc, y = stars_user)) + 
  geom_point(aes(color = as.factor(primaryDay), size = review_count_user), alpha = 0.5)  +
  theme_minimal()


ggplot(users_recast_merged, aes(total)) + geom_histogram()

users_melt_merged <- merge( users_melt, user_df, by = 'id_user')


require(ggplot2)

ggplot(users_melt_merged, aes(y = review_count_user, x = stars_user)) +
  geom_point(aes(color = as.factor(date_weekday), size = review_count_user), alpha = 0.4)+
  theme_minimal()

ggplot(multUserusers, aes(x = log(votes_useful_user), y = review_count_user)) +
  geom_point(aes(color = stars_user)) + facet_grid(.~primaryDay) +
  scale_colour_gradient2(high="darkred", mid="white", low = 'white')


ggplot(multUserusers, aes(conc)) + geom_boxplot(aes(primaryDay,conc)) 





require(maptools)
require(gdal)
require(maps)
require(RColorBrewer)

phoenix <- readShapeSpatial('1970_Subdivision')
phoenix.sp <- readShapeLines('1970_Subdivision.shp')
points(businesses_filtered$lon_business, businesses_filtered$lat_business, cex = 2, pch = 16, col = 'black')
plot(phoenix.sp, xlim=c(-113.5, -110), ylim=c(34.14,34.151))
# symbol plot -- equal-interval class intervals

plot(phoenix, xlim=c(-113.5, -110), ylim=c(34.15,34.151))

points(businesses_filtered$lon_business, businesses_filtered$lat_business, pch=23, col='red', cex=.6,)
points(businesses_filtered$lon_business, businesses_filtered$lat_business, cex=2)
title("Oregon Climate Station Data -- Annual Temperature",
      sub="Equal-Interval Class Intervals")




setwd(dir='~/Projects/yelp_phoenix_academic_dataset/CountySubdivision_1970/')

df_checkin <- read.table('../scripts/yelp_checkin.tsv', sep = '\t', stringsAsFactors=F, header = T)

require(plyr)
require(reshape2)
require(stringr)

extractWeekDay <- function(x){
  # extract week day from checkin info
  as.integer(strsplit(x, '\\.')[[1]][2])
}
extractHr <- function(x){
  # extract hour from checkin info  
  as.integer(strsplit(x, '\\.')[[1]][1])  
}

checkinData <- melt(df_checkin, id.vars='id_business')
checkinData$variable <- str_replace(checkinData$variable,'X','')
checkinData$weekDay <- sapply(checkinData$variable, extractWeekDay) 
checkinData$hr <- sapply(checkinData$variable, extractHr) 

checkinData <- checkinData[checkinData$hr >= 9,]

checkinData_byWeekDay <- ddply(.data = checkinData, .variables=c('id_business','weekDay'),
                               summarise,
                               numCheckins = sum(value))
require(reshape)
checkinData_byWeekDay_recast <- cast(checkinData_byWeekDay,
                                id_business ~ weekDay, fun.aggregate=sum)
weekdays <- c('sun','mon','tue','wed','thu','fri','sat')
names(checkinData_byWeekDay_recast)[2:8] <- weekdays
checkinData_byWeekDay_recast$funDays <- with(checkinData_byWeekDay_recast, (thu + fri + sat)/(sun + mon + tue + wed + thu + fri + sat))

setwd('~/Projects/yelp_phoenix_academic_dataset/scripts/')

businesses <- read.csv('yelp_business.tsv', sep  = '\t')

businesses_filtered = businesses[businesses$review_count_business>50,c('lon_business','lat_business','id_business')]

businesses_filtered <- merge(businesses_filtered, checkinData_byWeekDay_recast, by= 'id_business')

businesses_filtered$funBin <- cut(businesses_filtered$funDays,breaks=c(0,0.25, 0.5, 0.75,1))


setwd(dir='~/Projects/yelp_phoenix_academic_dataset/CountySubdivision_1970/')

require(ggmap)
mp <- get_map(location = c(lon = -112.0667, lat = 33.45), zoom = 10, maptype = 'roadmap')
map <- ggmap(mp)

map +
  geom_point(data = businesses_filtered, aes(x = lon_business, y = lat_business, color = as.factor(funBin)), size = 7, alpha = 1) + 
  scale_colour_manual(values = c('lightyellow','pink','red', 'darkred')) + 
  theme_minimal()


setwd('~/Projects/yelp_phoenix_academic_dataset/scripts/')

reviews <- read.csv('yelp_review.tsv', sep = '\t')

require(data.table)
dt <- data.table(reviews, key=c('id_business', 'date_weekday'))
unique_businesses <- dt[,list(ct=NROW(id_review)), by=c('id_business','date_weekday')]

bus_melt <- melt(data=unique_businesses, id.vars=c('id_business','date_weekday'))
bus_recast <- cast(bus_melt, id_business~date_weekday, sum)
weekdays <- c('sun','mon','tue','wed','thu','fri','sat')

names(bus_recast)[2:8] <- weekdays

bus_recast$funRev <- with(bus_recast, (thu + fri + sat)/(sun + mon + tue + wed + thu + fri + sat))

businesses_filtered_2 <- merge(businesses_filtered, bus_recast, by = 'id_business')

map +
  geom_point(data = businesses_filtered_2, aes(x = lon_business, y = lat_business, color = funRev), size = 7, alpha = 1) + 
  theme_minimal()


docStats <- data.frame(rbind(sun_df, mon_df, tues_df, wed_df, thurs_df, fri_df, sat_df))
docStats$day <- weekdays



