setwd('~/YelpDataAnalysis/')
df <- read.csv('data/processed/yelp_review.tsv', sep='\t')
View(df)
require(wordcloud)
require(tm)
corpus2dtm <- function(series){
  corpus <- Corpus(VectorSource(series))
  corpus <- tm_map(corpus, tolower)
  corpus <- tm_map(corpus, removePunctuation)
  corpus <- tm_map(corpus, removeNumbers)
  stopWords <- c(stopwords('SMART'))
  corpus <- tm_map(corpus, removeWords, stopWords)
  corpus <- tm_map(corpus, stemDocument)  
  dtm <- DocumentTermMatrix(corpus, control = list(minWordLength = 3))
}

require(RColorBrewer)
pal <- brewer.pal(5,'Reds')  

dtm_sun <- removeSparseTerms(corpus2dtm(df$text[df$date_weekday==0]), 0.95)
dtm_mon <- removeSparseTerms(corpus2dtm(df$text[df$date_weekday==1]), 0.95)
dtm_tue <- removeSparseTerms(corpus2dtm(df$text[df$date_weekday==2]), 0.95)
dtm_wed <- removeSparseTerms(corpus2dtm(df$text[df$date_weekday==3]), 0.95)
dtm_thu <- removeSparseTerms(corpus2dtm(df$text[df$date_weekday==4]), 0.95)
dtm_fri <- removeSparseTerms(corpus2dtm(df$text[df$date_weekday==5]), 0.95)
dtm_sat <- removeSparseTerms(corpus2dtm(df$text[df$date_weekday==6]), 0.95)

generateWordCloud <- function(dtm){
  wordcloud(words = colnames(dtm), freq = colSums(as.matrix(dtm)), max.words = 20, colors = pal)
}

require(ggplot2)

ggplot(df, aes(stars_review)) + geom_histogram() + facet_wrap(~date_weekday)

ggplot(df, aes(date_weekday)) + geom_histogram() + facet_wrap(~date_year)

ggplot(df, aes(date_weekday)) + geom_histogram() + facet_wrap(~date_month)

ggplot(df, aes(date_weekday)) + geom_histogram() + facet_wrap(~date_year)
