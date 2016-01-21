---
layout: post
title: whats cooking intro
comments: true
---

The first competition I entered came under the title "What's cooking" and involved predicting which part of the world recipes, that appeared on yummly.com, came from. I liked the sound of this competition, as I am a bit of a foodie - so it seemed like a good place to start. 

The data came in JSON format, giving an ID number, a list of ingredients and one of twenty cuisines. My principle goal for this competiton was to come up with a plan and execute it, hopefully coming up with a template for future projects, some reusable code and a few lessons learned. More important than getting a high score was understanding how and why a model might work and perhaps its limitations. In this post, I briefly go over how to get the data, get it ready to be analyzed and some simple analysis.

### Getting the data

Converting the data to a data.frame from JSON was pretty simple, using the `jsonlite` package. This flattens the hierarchical json file into one that is easier to work with in R. 

I then start using the `tm` package to put each item of ingredients into a Corpus, so we can start making transformations to the text and then create a Document Term Matrix that can be used in our various models. This matrix is essentially what is known as a 'bag of words', where each word in the recipe - regardless of what came before and after it.


{% highlight r %}
getTrainingData <- function(jsonFile) {
  # get data from json file and convert to data frame
  # Arg: the path of the json file
  train <- fromJSON(j, simplifyDataFrame = TRUE, flatten = TRUE)
  ingredients <- Corpus(VectorSource(train$ingredients))
  # future transformations to the ingredients will go here...
  
  #  convert to document term matrix and coerce to data.frame
  dtm <- as.data.frame(as.matrix(DocumentTermMatrix(ingredients)))
  # add dependent variable (cuisine) from train object
  dtm$DV_cuisine <- train$cuisine
  # Value:  a data frame with DV_cuisine for the cuisine and a column for each word in the 
  dtm # data.frame object returned
}

#dtm <- getTrainingData("train.json")
{% endhighlight %}



### Distribution of cuisines

There are twenty cuisines, as you can see below, the cuisines are not equally distributed. There are more Western cuisines than Eastern and quite a big proportion are Italian, Mexican, Indian, Southern US and Chinese.

![plot of chunk treemap](/figure/treemap-1.png) 

Below is a quick word cloud of the most common terms found in the ingredients lists. 
This gives us a bit of insight into how the data works, in our 'bag of words' structure
some of the words there don't seem to make much sense without the preceding word 
(such as paste, powder, leaves etc) and others seem to be redundant adjectives (fresh,
large, chopped) which probably don't tell us much about which cuisine the recipe might
belong to. I had a go at cleaning this data - and will explain hot this panned out in the next post.


{% highlight r %}
load("frq.Rda")
frq <- frq[1:90,]
wordcloud(frq$ing, frq$frq)
{% endhighlight %}

![plot of chunk wordcloud](/figure/wordcloud-1.png) 

## Setting up a partition

In order to test our models, we need to separate our training data into a further
training and testing set. I did this using the caret package. This allows us to test our algorithms on a number of different training sets, altering the proportion of the 
training/testing sets if we wish.


{% highlight r %}
library(caret)
getPartitionForSeed <- function(seed, dtm, p = 0.8) {
    set.seed(seed)
    createDataPartition(as.factor(dtm$DV_cuisine), p = p, list = FALSE)
}
{% endhighlight %}

Having done all of that, we're ready to start coming up with a prediction model.



