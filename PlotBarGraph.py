import matplotlib.pyplot as plt
import plotly.plotly as py
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

with open('catergory', 'rb') as handle:
  Category = pickle.load(handle)

#print Category


CategoryLen={}
for i in Category:
    temp=[]
    CategoryLen[i]=len(Category[i])

#print barchart to show numbers of movies for each catergory
bar1= plt.figure()

width=1/1.5
plt.bar(range(len(CategoryLen)), CategoryLen.values(),width,align='center')
plt.xticks(range(len(CategoryLen)), CategoryLen.keys())
#plot_url=py.plot_mpl(bar1,filename="Category_number")
plt.show()


Average={}
for i in Category:
    Average[i]=[]
    Average[i]=Category[i][0]

print Average.values()
bar2= plt.figure()
plt.bar(range(len(Average)), Average.values(), align='center')
plt.xticks(range(len(Average)), Average.keys())
#plot=url=py.plot_mpl(bar2,filename="Category_Average")
plt.show()
