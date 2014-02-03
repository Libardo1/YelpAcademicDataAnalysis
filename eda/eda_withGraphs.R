setwd('~/YelpDataAnalysis/')
require(ggplot2)
require(ggthemes)

## number of reviews by day of the week
numSun <- NROW(read.csv(file = 'data/processed/docStat_Sunday.csv'))
numMon <- NROW(read.csv(file = 'data/processed/docStat_Monday.csv'))
numTue <- NROW(read.csv(file = 'data/processed/docStat_Tuesday.csv'))
numWed <- NROW(read.csv(file = 'data/processed/docStat_Wednesday.csv'))
numThu <- NROW(read.csv(file = 'data/processed/docStat_Thursday.csv'))
numFri <- NROW(read.csv(file = 'data/processed/docStat_Friday.csv'))
numSat <- NROW(read.csv(file = 'data/processed/docStat_Saturday.csv'))

weekdays <- c('sun','mon','tue','wed','thu','fri','sat')

totalReviews <- data.frame(rbind(numSun, numMon, numTue, numWed, numThu, numFri, numSat))
totalReviews$Day <- factor(weekdays, as.character(weekdays))
names(totalReviews) <- c('numReviews','Day')

# Chart
ggplot(totalReviews,aes(Day,numReviews)) +
  geom_bar(stat = 'identity') +
  xlab('Day of the Week') + ylab('Number of Reviews') +
  theme_minimal()


### Number of check-ins by day of the week
df_checkin <- read.table('data/processed/yelp_checkin.tsv', sep = '\t', stringsAsFactors=F, header = T)

require(plyr)
require(reshape2)
require(stringr)

extractWeekDay <- function(x){
  # extract week day from checkin info
  strsplit(x, '\\.')[[1]][2]
}
extractHr <- function(x){
  # extract hour from checkin info  
  as.integer(strsplit(x, '\\.')[[1]][1])  
}

checkinData <- melt(df_checkin, id.vars='id_business')
checkinData$variable <- str_replace(checkinData$variable,'X','')
checkinData$weekDay <- sapply(checkinData$variable, extractWeekDay) 

totalCheckins <- ddply(.data = checkinData, .variables=c('weekDay'),
                       summarise,
                       numCheckins = sum(value))

num2day <- function(num){
  weekdays <- c('sun','mon','tue','wed','thu','fri','sat')
  weekdays[as.integer(num) + 1]  
}

totalCheckins$weekDay <- sapply(totalCheckins$weekDay, num2day)
totalCheckins$weekDay <- with(totalCheckins, factor(weekDay, as.character(weekDay)))

# Chart
ggplot(totalCheckins,aes(weekDay,numCheckins)) +
  geom_bar(stat = 'identity') +
  xlab('Day of the Week') + ylab('Number of Check-ins') +
  theme_minimal()


### build business-category dataset
df_business <- read.csv('data/processed/yelp_business.tsv', sep = '\t')

getCategory = function(df, categorylist){
  df$primaryCategory = NA  
  for (i in 1:length(categorylist)){
    df$primaryCategory[df[,categorylist[i]] == 1 & is.na(df$primaryCategory)] <- categorylist[i]
  }
  df$primaryCategory[is.na(df$primaryCategory)] <- "Other"
  df$primaryCategory
}

# these are some of the major categories. We will do it in reverse order so that smaller categories do not get underrepresented
categories_primary <- c('Active.Life','Nightlife','Beauty...Spas','Shopping','Restaurants')
df_business$primaryCategory <- getCategory(df_business, categories_primary)
business_categories <- df_business[, c('id_business','primaryCategory')]


getCategory = function(df, categorylist){
  # This will extract a primary category given a list of categories to scan for. Order is important since cats are not mutually exclusive..
  df$primaryCategory = NA  
  for (i in 1:length(categorylist)){
    df$primaryCategory[df[,categorylist[i]] == 1 & is.na(df$primaryCategory)] <- categorylist[i]
  }
  df$primaryCategory[is.na(df$primaryCategory)] <- "Other"
  df$primaryCategory
}


business_categories <- data.frame(business$id_business)
business_categories$primaryCategory <- getCategory(business, categories_primary)
names(business_categories) = c('id_business', 'primaryCategory')

### Reviews by category
df_reviews <- read.csv('data/processed/yelp_review.tsv', sep = '\t')

review_cat <- merge(df_reviews, business_categories, by = 'id_business')
review_cat <- review_cat[, c('primaryCategory','date_weekday')]

totalReviews_cat <- ddply(.data = review_cat, .variables=c('date_weekday','primaryCategory'),
                          summarise,
                          numReviews = NROW(primaryCategory))
totalReviews_cat$date_weekday <- sapply(totalReviews_cat$date_weekday, num2day)
totalReviews_cat$date_weekday <- with(totalReviews_cat, factor(date_weekday, as.character(date_weekday)))

# Chart
ggplot(totalReviews_cat,aes(date_weekday,numReviews, fill = primaryCategory)) +
  geom_bar(stat = 'identity') +
  xlab('Day of the Week') + ylab('Number of Reviews') +
  theme_minimal() 

### Check-ins by category

checkBus <- merge(checkinData, business_categories, by = 'id_business')
checkBus_melt <- melt(checkBus[,c('weekDay','value','primaryCategory')], id.vars=c('primaryCategory','weekDay'))

totalCheckins_cat <- ddply(.data = checkBus_melt, .variables=c('weekDay','primaryCategory'),
                           summarise,
                           numCheckins = sum(value))


totalCheckins_cat$weekDay <- sapply(totalCheckins_cat$weekDay, num2day)
totalCheckins_cat$weekDay <- with(totalCheckins_cat, factor(weekDay, as.character(weekDay)))

# Chart
ggplot(totalCheckins_cat,aes(weekDay,numCheckins, fill = primaryCategory)) +
  geom_bar(stat = 'identity') +
  xlab('Day of the Week') + ylab('Number of Check-ins') +
  theme_minimal() 

# Identify cut-offs for popular and high quality establishments. Inspect histograms

ggplot(df_business,aes(review_count_business)) + geom_histogram() # cutoffs: Less than 25, More than 150
df_business$popular <- NA
df_business$popular[df_business$review_count_business < 25] <- 'Popular'
df_business$popular[df_business$review_count_business > 150] <- 'Not popular'
business_popularity <- df_business[is.na(df_business$popular) == F,c('id_business','popular','quality')]

ggplot(df_business,aes(stars_business)) + geom_histogram() # 2.5, 4.5

df_business$quality <- NA
df_business$quality[df_business$stars_business <=2.5] <- 'Poorly rated'
df_business$quality[df_business$stars_business >=4.5] <- 'Highly rated'
business_quality <- df_business[is.na(df_business$quality) == F, c('id_business', 'popular','quality')]

checkPopular <- merge(checkinData, business_popularity, by = 'id_business')
checkPopular_melt <- melt(checkPopular[,c('weekDay','value','popular')], id.vars=c('popular','weekDay'))
totalCheckins_pop <- ddply(.data = checkPopular_melt, .variables=c('weekDay','popular'),
                           summarise,
                           numCheckins = sum(value))

totalCheckins_pop$weekDay <- sapply(totalCheckins_pop$weekDay, num2day)
totalCheckins_pop$weekDay <- with(totalCheckins_pop, factor(weekDay, as.character(weekDay)))

# Chart
ggplot(totalCheckins_pop,aes(weekDay,numCheckins, fill = popular)) +
  geom_bar(stat = 'identity') +
  xlab('Day of the Week') + ylab('Number of Check-ins') +
  theme_minimal() 

checkQuality <- merge(checkinData, business_quality, by = 'id_business')
checkQuality_melt <- melt(checkQuality[,c('weekDay','value','quality')], id.vars=c('quality','weekDay'))
totalCheckins_qual <- ddply(.data = checkQuality_melt, .variables=c('weekDay','quality'),
                            summarise,
                            numCheckins = sum(value))

totalCheckins_qual$weekDay <- sapply(totalCheckins_qual$weekDay, num2day)
totalCheckins_qual$weekDay <- with(totalCheckins_qual, factor(weekDay, as.character(weekDay)))

# Chart
ggplot(totalCheckins_qual,aes(weekDay,numCheckins, fill = quality)) +
  geom_bar(stat = 'identity') +
  xlab('Day of the Week') + ylab('Number of Check-ins') +
  theme_minimal() 



###We can use first names to estimate user gender
# Data taken from Census Bureau
require(RCurl)
census_male <- read.table(
  textConnection(getURL('http://www.census.gov/genealogy/www/data/1990surnames/dist.male.first')))
census_male <- census_male[,1:2]
census_male[,1] <- tolower(census_male[,1])
census_male[,2] <- 'Male'

census_female <- read.table(
  textConnection(getURL('http://www.census.gov/genealogy/www/data/1990surnames/dist.female.first')))
census_female <- census_female[,1:2]
census_female[,1] <- tolower(census_female[,1])
census_female[,2] <- 'Female'

namesGender <- rbind(census_male, census_female)
names(namesGender) <- c('name','gender')

df_users <- read.csv('data/processed/yelp_user.tsv', sep = '\t')

users_name <- df_users[, c('id_user','name_user')]
users_name$name_user <- tolower(users_name$name_user)
users_name_gender <- merge(users_name, namesGender, by.x = 'name_user', by.y = 'name', all.x = T)
NROW(users_name_gender[is.na(users_name_gender$gender),])
# 7466 out of 57470 users were not assigned genders. OK

users_gender <- users_name_gender[is.na(users_name_gender$gender) == F, c('id_user','gender')]
table(users_gender$gender)
# ~30,000 females, 20,000 males

review_gender <- merge(df_reviews, users_gender, by = 'id_user')
review_gender <- review_gender[, c('gender','date_weekday')]

totalReviews_sex <- ddply(.data = review_gender, .variables=c('date_weekday','gender'),
                          summarise,
                          numReviews = NROW(gender))
totalReviews_sex$date_weekday <- sapply(totalReviews_sex$date_weekday, num2day)
totalReviews_sex$date_weekday <- with(totalReviews_sex, factor(date_weekday, as.character(date_weekday)))

# Chart
ggplot(totalReviews_sex,aes(date_weekday,numReviews, fill = gender)) +
  geom_bar(stat = 'identity') +
  xlab('Day of the Week') + ylab('Number of Reviews') +
  theme_minimal() 

#### Merge user sentiment (positive vs negative reviewer) to review dataset

users_sentiment <- df_users[,c('id_user','stars_user')]
ggplot(users_sentiment, aes(stars_user)) + geom_histogram() # cutoff 3 and 4.5

users_sentiment$sentiment <- NA
users_sentiment$sentiment[users_sentiment$stars_user >= 4.5] <- 'Positive'
users_sentiment$sentiment[users_sentiment$stars_user < 3] <- 'Negative'
users_sentiment <- users_sentiment[is.na(users_sentiment$sentiment)==F, c('id_user','sentiment')]

users_activity <- df_users[,c('id_user','review_count_user')]
ggplot(users_activity, aes(review_count_user)) + geom_histogram() #cutoff 100+ reviews, and 1-3 reviews

users_activity$activity <- NA
users_activity$activity[users_activity$review_count_user >= 100] <- '100+ reviews'
users_activity$activity[users_activity$review_count_user <= 3] <- '1-3 reviews'
users_activity <- users_activity[is.na(users_activity$activity)==F, c('id_user','activity')]

users_reception <- df_users[,c('id_user','review_count_user','votes_useful_user','votes_cool_user','votes_funny_user')]

# Measure reception as the average number of votes from each category, scaled by the number of reviews the user has. Better metric
users_reception_2 <- users_reception
users_reception_2$votes_useful_user <- with(users_reception_2, votes_useful_user/review_count_user)
users_reception_2$votes_cool_user <- with(users_reception_2, votes_cool_user/review_count_user)
users_reception_2$votes_funny_user <- with(users_reception_2, votes_funny_user/review_count_user)

# Measure reception as the total number of votes ---no good
users_reception$numVotes <- with(users_reception, votes_useful_user + votes_cool_user + votes_funny_user)

users_reception <- users_reception[,c('id_user','numVotes')]


### Plot sentiment
review_sent <- merge(df_reviews, users_sentiment, by = 'id_user')
review_sent <- review_sent[, c('sentiment','date_weekday')]

totalReviews_sentiment <- ddply(.data = review_sent, .variables=c('date_weekday','sentiment'),
                                summarise,
                                numReviews = NROW(sentiment))

totalReviews_sentiment$date_weekday <- sapply(totalReviews_sentiment$date_weekday, num2day)
totalReviews_sentiment$date_weekday <- with(totalReviews_sentiment, factor(date_weekday, as.character(date_weekday)))

# Chart
ggplot(totalReviews_sentiment,aes(date_weekday,numReviews, fill = sentiment)) +
  geom_bar(stat = 'identity') +
  xlab('Day of the Week') + ylab('Number of Reviews') +
  theme_minimal() 

### Plot activity
review_active <- merge(df_reviews, users_activity, by = 'id_user')
review_active <- review_active[, c('activity','date_weekday')]

totalReviews_activity <- ddply(.data = review_active, .variables=c('date_weekday','activity'),
                               summarise,
                               numReviews = NROW(activity))

# Chart
ggplot(totalReviews_activity,aes(date_weekday,numReviews, fill = activity)) +
  geom_bar(stat = 'identity') +
  xlab('Day of the Week') + ylab('Number of Reviews') +
  theme_minimal() 

#### Plot reception
review_reception <- merge(df_reviews, users_reception, by = 'id_user')
review_reception <- review_reception[,c('numVotes','date_weekday')]

totalReviews_reception <- ddply(.data = review_reception, .variables=c('date_weekday'),
                                summarise,
                                numReviews = NROW(numVotes),
                                avgVotes = mean(numVotes))

ggplot(totalReviews_reception,aes(date_weekday,numReviews, fill = avgVotes)) +
  geom_bar(stat = 'identity') +
  xlab('Day of the Week') + ylab('Number of Check-ins') +
  theme_minimal() + 
  ggtitle('Review behavior is uniform across the days of the week between sexes')

#### Plot reception (2)
review_reception_2 <- merge(df_reviews, users_reception_2, by = 'id_user')
review_reception_2 <- review_reception_2[,c('date_weekday','votes_useful_user','votes_funny_user','votes_cool_user')]

totalReviews_reception_2 <- ddply(.data = review_reception_2, .variables=c('date_weekday'),
                                  summarise,
                                  avgUseful = mean(votes_useful_user),
                                  avgFunny = mean(votes_funny_user),
                                  avgCool = mean(votes_cool_user))

totalReviews_reception_2$date_weekday <- sapply(totalReviews_reception_2$date_weekday, num2day)
totalReviews_reception_2$date_weekday <- with(totalReviews_reception_2, factor(date_weekday, as.character(date_weekday)))


ggplot(totalReviews_reception_2,aes(avgUseful,avgCool, color = date_weekday)) +
  geom_point(size = 10) +
  xlab('Day of the Week') + ylab('Number of Check-ins') +
  theme_minimal() + 
  ggtitle('Review behavior is uniform across the days of the week between sexes')

ggplot(totalReviews_reception_2,aes(avgCool,avgFunny, color = date_weekday)) +
  geom_point(size = 10) +
  xlab('Day of the Week') + ylab('Number of Check-ins') +
  theme_minimal() + 
  ggtitle('Review behavior is uniform across the days of the week between sexes')

# Chart
ggplot(totalReviews_reception_2,aes(avgUseful,avgFunny, color = date_weekday)) +
  geom_point(size = 10) +
  xlab('Average # of Useful Votes') + ylab('Average # of Funny Votes') +
  theme_minimal() 




#########  Other interesting things 

###Time and Day check-ins
checkinData$hr <- sapply(checkinData$variable, extractHr) 
checkinData_byDayHr <- ddply(.data = checkinData, .variables=c('weekDay', 'hr'),
                             summarise,
                             numCheckins = sum(value))

checkinData_byDayHr$weekDay <- sapply(checkinData_byDayHr$weekDay, num2day)
checkinData_byDayHr$weekDay <- with(checkinData_byDayHr, factor(weekDay, as.character(weekDay)))

# Chart
ggplot(checkinData_byDayHr, aes(hr,numCheckins)) +
  geom_line(aes(color = weekDay)) + geom_point(aes(color = weekDay)) +
  xlab('Hour of the day') + ylab('Number of Check-ins') + 
  theme_minimal()


weekDay.Hr.Cat <- ddply(.data = merge(checkinData,business_categories, by='id_business'), 
                        .variables=c('weekDay', 'hr', 'primaryCategory'), 
                        summarise,
                        numCheckins = sum(value))

weekDay.Hr.Cat$weekDay <- sapply(weekDay.Hr.Cat$weekDay, num2day)
weekDay.Hr.Cat$weekDay <- with(weekDay.Hr.Cat, factor(weekDay, as.character(weekDay)))

# Chart
ggplot(weekDay.Hr.Cat, aes(x = as.integer(hr), y = numCheckins)) +
  geom_line(aes(group = as.factor( weekDay), color = weekDay)) + geom_point(aes(color =  weekDay)) +
  facet_grid(. ~ primaryCategory) +
  xlab('Hours in the day') + ylab('Total Number of Checkins') +
  theme_minimal() + guides(fill = guide_legend(reverse = TRUE))



### Statistics on reviews - Number of words, word length, sentence length, vocabulary diversity. Not very interesting across days of week.
revSun <- read.csv(file = 'data/processed/docStat_Sunday.csv')
revSun$weekDay <- 'sun'
revMon <- read.csv(file = 'data/processed/docStat_Monday.csv')
revMon$weekDay <- 'mon'
revTue <- read.csv(file = 'data/processed/docStat_Tuesday.csv')
revTue$weekDay <- 'tue'
revWed <- read.csv(file = 'data/processed/docStat_Wednesday.csv')
revWed$weekDay <- 'wed'
revThu <- read.csv(file = 'data/processed/docStat_Thursday.csv')
revThu$weekDay <- 'thu'
revFri <- read.csv(file = 'data/processed/docStat_Friday.csv')
revFri$weekDay <- 'fri'
revSat <- read.csv(file = 'data/processed/docStat_Saturday.csv')
revSat$weekDay <- 'sat'



revStats <- data.frame(rbind(revSun, revMon, revTue, revWed, revThu, revFri, revSat))
## Unique users and businesses

revStats_melt <- melt(revStats, id.vars= c('weekDay'))

avgStats <- ddply(revStats, .variables='weekDay',summarise,
                  avgNumberOfWords = mean(Number.of.Words),
                  avgSentenceLength = mean(Average.Sentence.Length),
                  sdNumberofWords = sd(Number.of.Words))

# Chart
ggplot(avgStats, aes(weekDay, avgNumberOfWords)) + geom_bar(stat = 'identity')
# No significant differences among days of the week.


### Geo activity
businesses_geo = df_business[df_business$c,c('lon_business','lat_business','id_business')]

checkinData_byWeekDay <- ddply(.data = checkinData, .variables=c('id_business','weekDay'),
                               summarise,
                               numCheckins = sum(value))
checkinData_byWeekDay <- recast(checkinData_byWeekDay,
                                id_business ~ weekDay,fun.aggregate=sum)
names(checkinData_byWeekDay)[2:8] <- weekdays
checkinData_byWeekDay$funDays <- with(checkinData_byWeekDay, (thu + fri + sat)/(sun + mon + tue + wed + thu + fri + sat))

checkinGeo <- merge(businesses_geo, checkinData_byWeekDay, by= 'id_business')
checkinGeo$funDays2 <- cut(checkinGeo$funDays,breaks=c(0, 0.85,1))

require(ggmap)
mp <- get_map(location = c(lon = -112.0667, lat = 33.45), zoom = 10, maptype = 'roadmap')
map <- ggmap(mp)

# Chart
map +
  geom_point(data = checkinGeo[checkinGeo$funDays<0.9,], aes(
    x = lon_business, y = lat_business), color = 'gray20', size = 4, alpha = 0.25) +
  geom_point(data = checkinGeo[checkinGeo$funDays>=0.9,], aes(
    x = lon_business, y = lat_business),color = 'red', size = 4, alpha = 0.6) +
  scale_colour_manual(values = c('gray34','orangered')) + 
  theme_minimal()


#### unsupervised classifications 

df_business2 <- read.csv('data/processed/business_withLabels.tsv', sep = '\t')
business_categories_custom = df_business2[, c('id_business','label')]
review_cat2 <- merge(df_reviews, business_categories_custom, by = 'id_business')
review_cat2 <- review_cat2[, c('label','date_weekday')]

totalReviews_cat2 <- ddply(.data = review_cat2, .variables=c('date_weekday','label'),
                           summarise,
                           numReviews = NROW(label))
totalReviews_cat2$date_weekday <- sapply(totalReviews_cat2$date_weekday, num2day)
totalReviews_cat2$date_weekday <- with(totalReviews_cat2, factor(date_weekday, as.character(date_weekday)))

lab2text <- function(num){
  customlabs = c('Automotive services', 'Food/dining', 'Shopping', 'Financial/Real-Estate services', 'Beauty/Spa/Personal services', 'Other maintenance/repair services', 'Medical/education services', 'Nightlife/social experiences')
  customlabs[as.integer(num) + 1]  
}

totalReviews_cat2$label <- sapply(totalReviews_cat2$label, lab2text)
totalReviews_cat2$label <- with(totalReviews_cat2, factor(label, as.character(label)))

# Chart
ggplot(totalReviews_cat2,aes(date_weekday,numReviews, fill = label)) +
  geom_bar(stat = 'identity') +
  xlab('Day of the Week') + ylab('Number of Reviews') +
  theme_minimal() 