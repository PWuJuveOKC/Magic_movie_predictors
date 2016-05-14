library("ggplot2")
library("ggplot2movies")
library("sqldf")
library("randomForest")
library("e1071")
library("dbscan")
library("cluster")

setwd("/Users/pw2394/Dropbox/Columbia University/Big Data Project")

### from ggplot2movies dataset

data(movies)
votes <- sqldf('SELECT votes FROM movies WHERE votes > 2000')
movies1 <- sqldf('SELECT * FROM movies WHERE votes > 2000')
table(movies1$mpaa)

movies1$mpaa <- as.numeric(factor(movies1$mpaa))
movies1 <- sqldf( 'SELECT * FROM movies1 ORDER BY votes DESC, year DESC, rating DESC')
movies2 <- sqldf('SELECT rating,year, length, budget, votes, mpaa, Action, Animation, Comedy, Drama, Documentary, Romance,
                     Short From movies1')

library(gridExtra)
hist1 <- qplot(rating, data = movies2, geom = 'histogram', bins = 20, main = 'Histogram of Ratings', 
        xlab='Ratings', ylab = 'Frequencies',fill=I("red"), 
        col=I("black"))
hist2 <- qplot(budget, data = movies2, geom = 'histogram', bins = 20, main = 'Histogram of Budgets', 
        xlab='Budgets', ylab = 'Frequencies',fill=I("blue"), 
        col=I("black"))
grid.arrange(hist1, hist2, nrow=2)

set.seed(123)
movies.imp <- rfImpute(rating ~ ., data = movies2, ntree = 300)

## scale

movies.test <- scale(movies.imp)

## visualization

### Below is modified from 
## http://www.r-bloggers.com/top-250-movies-at-imdb/;

ggplot(movies.imp, aes(x = year, y = rating,color=mpaa)) +
  geom_point(aes(size = budget), alpha = 0.3, position = "jitter") +
   scale_size(range = c(3, 15)) +   theme_light()


################# Supervised Learning: Random Forests ####################
##########################################################################

set.seed(823)
train_size <- floor(2/3 * nrow(movies.imp))
train_ind <- sample(seq_len(nrow(movies.imp)), size = train_size)

train <- movies.imp[train_ind, ]
test <- movies.imp[-train_ind, ]

set.seed(123)
movies.rf <- randomForest(rating~., data = train,ntree = 500,importance=T )
head(movies.rf$importance)
varImpPlot(movies.rf,main='Variable Importance Plot')
plot(movies.rf,main='Error vs # Trees')

set.seed(123)
movies.rf <- randomForest(rating~., data = train,ntree = 80,importance=T )


newdata <- test[,-1]
rating <- test[,1]

test.pred.rf <- predict(movies.rf,newdata,type='response')
sqrt.err.rf <- 1 / length(rating) * sqrt(sum((rating - test.pred.rf)^2)) #0.026
abs.err.rf <- 1 / length(rating) * abs(sum(rating - test.pred.rf)) #0.011

plot (rating ~ test.pred.rf,main='Random Forests Prediction Plot',xlab='Predicted Rating', 
      ylab='Rating',col='darkgreen',pch=3)
abline(0,1,col='red',lwd=2)

## prediction result example
index1 <- rownames(test[1:5,])
movies1$title[as.numeric((index1))]


################# Supervised Learning: SVM ###############################
##########################################################################

## Below is modidied sample code from R package CRAN
obj <- tune.svm(rating~., data = train, sampling = "fix",
                gamma = 2^c(-8,-4,0,4), cost = 2^c(-8,-4,-2,0))
plot(obj, type = "perspective", theta = 120, phi = 45, col ='red')
## cost = 1 gamma = 0.0625

movies.svm <- svm(rating~., data = train, cost = 1, gamma = 0.0625)

tunedModel <- obj$best.model
tunedModelY <- predict(movies.svm, newdata = newdata) 

error <- rating - tunedModelY  

sqrt.err.svm <- 1 / length(rating) * sqrt(sum((rating - tunedModelY)^2)) #0.026
abs.err.svm <- 1 / length(rating) * abs(sum(rating - tunedModelY)) #0.060



#################### Unsupervised Learning: Clustering ###################
##########################################################################


## use within cluster SS to choose optimal K

#### Below ismodified from 
# https://rstudio-pubs-static.s3.amazonaws.com/33876_1d7794d9a86647ca90c4f182df93f0e8.html;
wss.curve <- function(data, center = 10, seed = 823){
  wss <- (nrow(data)-1) * sum(apply(data,2,var))
  for (i in 2:center) {
    set.seed(seed)
    wss[i] <- sum(kmeans(data, centers=i, iter.max = 100)$withinss)}
  
  plot(1:center, wss, type="b", xlab="Number of Clusters",
       ylab="Within groups sum of squares",col='blue',pch='o',lty=2,
       main='Optimal K')}

wss.curve (movies.test) ## K = 4


## clustering on optimal regularization params
movies.test <- movies.test[,-1]

set.seed(823)
clus.res <- kmeans(movies.test,centers = 4,iter.max = 100)

title <- movies1[,1]
rating <- movies1$rating
clus1 <- title[clus.res$cluster==1]
clus2 <- title[clus.res$cluster==2]
clus3 <- title[clus.res$cluster==3]
clus4 <- title[clus.res$cluster==4]
rating1 <- rating[clus.res$cluster==1]
rating2 <- rating[clus.res$cluster==2]
rating3 <- rating[clus.res$cluster==3]
rating4 <- rating[clus.res$cluster==4]

##view the results
clusplot(movies.test, clus.res$cluster,color=T,shade=T,lines=0,labels=1,
         main = 'View the Clustering Results', xlab='',
         ylab='')

## dbscan

dat.db <- as.matrix(movies.test[,-1])
wt <-  movies.imp$votes / (2010 - movies.imp$year)
set.seed(823)
scan.res <- dbscan(dat.db,eps=2,minPts = 5,weights=wt)
res1<-scan.res$cluster
res2<-table(res1)[table(res1)>200]

ind1 <- which(res1==7)
dbclus1 <- title[ind1]
dbrating1 <- rating[ind1]
mean(dbrating1) #7.1

ind2 <- which(res1==15)
dbclus2 <- title[ind2]
dbrating2 <- rating[ind2]
mean(dbrating2) #5.8


ind3 <- which(res1==18)
dbclus3 <- title[ind3]
dbrating3 <- rating[ind3]
mean(dbrating3) #6.2



ind4 <- which(res1==22)
dbclus4 <- title[ind4]
dbrating4 <- rating[ind4]
mean(dbrating4) #6.5


ind5 <- which(res1==31)
dbclus5 <- title[ind5]
dbrating5 <- rating[ind5]
mean(dbrating5) #6.7



ind6 <- which(res1==35)
dbclus6 <- title[ind6]
dbrating6 <- rating[ind6]
mean(dbrating6) #5.9

