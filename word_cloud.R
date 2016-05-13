library(httr)  
library(bit64)  
library(twitteR)

library(RCurl)
library(RJSONIO)
library(stringr)


library(tm)
library(DescTools)
library(sqldf)
library(wordcloud)

setwd("/Users/Dropbox/Columbia University/Big Data Project")

#Twitter API key and secret
api_key <- "*************************" 
api_secret <- "*************************" 
token <- "*************************" 
token_secret <- "*************************" 

#Datumbox API key
datum_key <- "*************************"

# Twitter Connection
setup_twitter_oauth(api_key, api_secret, token, token_secret)

tweets_zoo <- searchTwitter("#Zootopia OR #zootopia",n = 2500,lang="en",since="2016-01-01")
tweets_rev<-searchTwitter("#TheRevenant OR #therevenant",n=1500,lang="en",since="2015-12-24")


#########################################################################################
########## Reference: http://www.r-bloggers.com/create-twitter-wordcloud-with-sentiments/
########## https://github.com/JulianHill/R-Tutorials ####################################
#########################################################################################

########################### Zootopia ####################
#########################################################

#### Below is modified from:
## http://www.r-bloggers.com/create-twitter-wordcloud-with-sentiments/

### text clean and datumbox call for sentiment is 
### from https://github.com/JulianHill/R-Tutorials/blob/master/sentiment_datumbox.r

tweets_zoo2 = sapply(tweets_zoo, function(x) x$getText())
tweets_clean = clean.text(tweets_zoo2)
tweets_clean <- unique(tweets_clean)
size <- length(tweets_clean)
tweets_zoo_df <- data.frame(text = tweets_clean, 
                          sentiment = rep("", size),stringsAsFactors=F)



tweets_zoo_df <- sqldf('SELECT * FROM tweets_zoo_df WHERE text != "<NA>"')

# write.csv(tweets_zoo_df,'clean_zoo_df.csv',row.names = F)
# tweets_zoo_df <- read.csv('clean_zoo_df.csv')
# size <- dim(tweets_zoo_df)[1]

#Sentiment
for (i in 1:size) {
  
  sent_temp = getSentiment(tweets_clean[i], datum_key)
  tweets_zoo_df$sentiment[i] <- sent_temp$sentiment
  print(paste(i,"/", size, " completed"))
  
}


tweets_zoo_df1 <- sqldf('SELECT * FROM tweets_zoo_df WHERE 
                        sentiment == "positive" OR sentiment == "negative" 
                        OR sentiment == "neutral"')
sent_lev <- rownames(table(tweets_zoo_df1$sentiment))



########################### Revenant ####################
#########################################################

tweets_rev2 = sapply(tweets_rev, function(x) x$getText())
tweets_clean = clean.text(tweets_rev2)
tweets_clean <- unique(tweets_clean)
size <- length(tweets_clean)
tweets_rev_df <- data.frame(text = tweets_clean, 
                            sentiment = rep("", size),stringsAsFactors=F)



tweets_rev_df <- sqldf('SELECT * FROM tweets_rev_df WHERE text != "<NA>"')



#Sentiment
for (i in 1:size) {
  
  sent_temp = getSentiment(tweets_clean[i], datum_key)
  tweets_rev_df$sentiment[i] <- sent_temp$sentiment
  print(paste(i,"/", size, " completed"))
  
}


tweets_rev_df1 <- sqldf('SELECT * FROM tweets_rev_df WHERE 
                        sentiment == "positive" OR sentiment == "negative" 
                        OR sentiment == "neutral"')


sent_lev <- rownames(table(tweets_rev_df1$sentiment))


########################## Corpus and Cloud ########################
####################################################################

df <- tweets_rev_df

legend <- lapply(sent_lev, function(y) 
                        paste(y,format(round((length((df[df$sentiment ==y,])$text)
                                              /length(df$sentiment)*100),1),nsmall=1),"%"))
num <- length(sent_lev)
edocs <- rep("", num)

for (i in 1:num)
  {
  temp <- df[df$sentiment == sent_lev[i],]$text
  
  edocs[i] <- paste(temp,collapse=" ")
  }


# remove stopwords

edocs <- removeWords(edocs, stopwords("english"))

corpus <- Corpus(VectorSource(edocs))
word.mat <- as.matrix(TermDocumentMatrix(corpus))
colnames(word.mat) <- legend

pdf("WordCloud2.pdf", width=12, height=8)
comparison.cloud(word.mat, max.words = floor(size /20),colors = c("#00B2FF", "red", "#FF0099", "#6600CC"),
                 scale = c(4.5,1.5), random.order = FALSE, title.size = 1.8)
dev.off()



