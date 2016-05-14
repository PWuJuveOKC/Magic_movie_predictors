import matplotlib.pyplot as plt

from imdbpie import Imdb
imdb = Imdb()
imdb = Imdb(anonymize=True) # to proxy requests

import pickle
import ast
import json
movie=open('movie review score_0-50','r')
movie1=open('movie review score_51-100','r')
movie2=open('movie review score_101-150','r')
movie3=open('movie review score_151-200','r')
movie4=open('movie review score_201-250','r')
#dictionary=dict(x.split(':') for x in movie.read().split('],'))
#print dictionary
Scores= eval(movie.read())
Scores.update(eval(movie1.read()))
Scores.update(eval(movie2.read()))
Scores.update(eval(movie3.read()))
Scores.update(eval(movie4.read()))
print len(Scores)
#temp=[]
#temp.append(float(Scores['tt1675434'][0]))
#print temp
MovieSentScore={}
id=[]

#average=[]
for i in Scores:
    temp=[]
    MovieSentScore[i]=[]

    #id.append(i)
    for j in range(len(Scores[i])):
        temp.append(float(Scores[i][j]))
    #average.append(sum(temp)/len(Scores[i]))
    MovieSentScore[i].append(sum(temp)/len(Scores[i]))
    #print len(average)
    #rint len(id)


#print MovieSentScore
plot=[]
for i in MovieSentScore:
    plot.append(MovieSentScore[i][0])
    #print MovieSentScore[i][0]
    #plt.plot(MovieSentScore[i])
    #plt.show()
#print plot



#plot graph
Average=[]
for i in range(len(plot)):
    Average.append(sum(plot)/len(plot))
print Average
plt.scatter(range(len(plot)),plot)
plt.plot(Average,'r',linewidth=2.0)
plt.ylabel('sentiment score for each movie')
plt.title('sentiment score distribution')
plt.show()

#put movies into Categories
Category={}
for i in Scores:
    print i
    movieTitle=imdb.get_title_by_id(i)
    Gen=movieTitle.genres
    for j in Gen:
        print j
        if (not Category.has_key(str(j))):
            Category[j]=[]
            print MovieSentScore[i][0]
            print Category[str(j)].append(MovieSentScore[i][0])
            Category[str(j)].append(MovieSentScore[i][0])
        else:
            print Category[str(j)].append(MovieSentScore[i][0])
            Category[str(j)].append(MovieSentScore[i][0])
print Category

with open('catergory','wb') as handle:
    pickle.dump(Category,handle)
