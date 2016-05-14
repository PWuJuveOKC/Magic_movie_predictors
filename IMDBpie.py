from alchemyapi import AlchemyAPI
alchemyapi=AlchemyAPI()
from imdbpie import Imdb
imdb = Imdb()
imdb = Imdb(anonymize=True) # to proxy requests

# Creating an instance with caching enabled
# Note that the cached responses expire every 2 hours or so.
# The API response itself dictates the expiry time)
imdb = Imdb(cache=True)
top_mov = imdb.top_250()


rating = []
title = []
id = []
votes = []
prod_year = []
for i in range(len(top_mov)):
    rating.append(top_mov[i]['rating'])
    title.append(top_mov[i]['title'])
    id.append(top_mov[i]['tconst'])
    votes.append(top_mov[i]['num_votes'])
    prod_year.append(top_mov[i]['year'])

#print rating

reviews={}
reviewScore={}
num = 15
for item in id[201:250]:
    reviews[item] = []
    reviewScore[item] = []
    for j in range(num):
        review=imdb.get_title_reviews(item, max_results = num)[j].text
        print review
        reviews[item].append(review)
        response= alchemyapi.sentiment("html",review)
        if 'score' in response['docSentiment']:
            reviewScore[item].append(response["docSentiment"]['score'])
            reviews[item].append(response["docSentiment"]['score'])

print reviewScore
#print review
reviewsOutput=open("movie reviews_201-250)",'w')
reviewsOutput.write(str(reviews))

reviewScoreOutput=open("movie review score_201-250",'w')
reviewScoreOutput.write(str(reviewScore))
print len(id)
