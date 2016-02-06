---
layout: post
title: whats cooking results
comments: true
---

ok. so wrapping up.

I feel I only just got started getting somewhere with this project about a week after the deadline. So I’ve made a decision to stop and move on. But below are a reasonably neat. 

I set up the data in a way that I can produce around 400 variables either as words in a simple bag of words model that takes out features that do not appear in at least 0.1% of recipes. This was my starting point and yielded a 73.0% success rate.

I added another function to transform the text on three key problems that looked wrong.

A third function takes all the words and condenses them into 400 variables using singular vector decomposition.

This gives me three possible data frames to test out two different models: a multi-nominal logistic regression model using the `nnet` package and a random forest model using `h2o` package. The initial model is pretty reliable. 

### text transformation

Somewhat surprisingly, the text transformations make the model a little worse, rather than better. In previous testing, I had chosen N variables to be in the model. So a bad variable was taking the place of a potentially better one. But with the method of choosing variables based on the proportion of recipes it appears in removes this possibility. All it does is make the individual variables a little more intuitive for the person interpreting the coefficients without improving the performance of predicting on the testing data. The success rate dropped to 71.2% with this model.

### single vector decomposition (with multinomial logistic regression

Using the SVD should work better for our logistic regression. Rather than clumsily messing with the data, as I had done before, it compresses the full data (including the very sparse terms) into a single matrix that is manageable for our regression model so contains more signal and less noise. It does improve our predictions a little, rather than being a substantial improvement. But an improvement of only 1% can make a big difference for gaggle competitions. This prediction took me up to 74.9%

### random forest

For random forest, as before, the initial data works quite well - though not quite as well as the logistic regression model - 72.9%. Applying the SVD model is much less effective. This makes sense, as the removal of that sparse data is presumably more geared towards regression model type algorithms than decision tree models. So while it doesn’t ruin the predictions - it does add some error.

And there we go… next up: AirBnB