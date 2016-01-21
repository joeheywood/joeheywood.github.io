---
layout: post
title: (whats cooking) predictions with logistic regression
comments: true
---

I decided to start off with a simple model that I know well - logistic regression.
I'm sure that there are other, more effective ways of classifying our data, but
at this early stage, I decided to stick with what I know.

In this case, we need to come up with a logit model that can handle several categories,
not just two. The twenty cuisines here are very much nominal categories, so they 
cannot be put into any kind of order, or given a numerical value that could 
correspond to the various cuisines.

What we are looking for is a **multinomial** logit model. Here, one category is removed 
and the coefficients for each variable (each word for us) corresponds to whether 
each possible category is more or less likely than the reference category. It 
works in a similar way to producing a separate logistic regression for each category
and comparing the predictions. The crucial difference is that the comparison is with a 
single category, rather than the entire sample.


{% highlight r %}
trainLogit <- function(dtm, inTrain) {
    # create multinomial model. 
    # Args: dtm (data.frame), 
    # inTrain(numeric vector) - for partition if needed - if not select 1:nrow(dtm)
    # value multinomial logistic regression model (nnet::multinom)
    multinom(DV_cuisine ~ ., data = dtm[inTrain,], MaxNWts = 10000)
}

testLogit <- function(mod, testData) {
    # test multinomial logistic regression model
    # Args: mod nnet:multinom object, 
    # testData (data.frame) data on which to test model
    # should include column 'correct' with correct cuisine category
    preds <- predict(mod, testData)
    probs <- predict(mod, testData, type = "probs")
    bestProb <- sapply(1:length(preds), function(x) {
        probs[x, preds[x]]
    })
    # Value data frame with nrow(testData) rows and columns:
    # correct - the correct cuisine, prediction - the predicted cuisine
    # probs - the probability value for the best option and isCorr (bool) if prediction is correct
    data.frame(correct = testData$DV_cuis, prediction = preds,
               probs = bestProb, isCorr = dtm$DV_cuisine[-inTrain] == preds)
}

runLogit <- function(seed) {
    # run model for a given seed (numeric). Get data from train.json,
    # create data partition from seed, create model on training partition, then test on test partition
    dtm <- getTrainingData("train.json")
    inTrain <- getPartitionForSeed(seed, dtm)
    logitModel <- trainLogit(dtm, inTrain)
    # Value data.frame (from testLogit above)
    testLogit(logitModel, dtm[-inTrain])
}
{% endhighlight %}

When we run the predict command on our testing data, we get the predicted value 
and when we run the same command, but with the `type = "probs"` argument, we get a 
matrix of probablities of (number of cases) x (possible categories). 

The prediction, at this point matches the correct answer 69.9% of the time, 
which isn't terrible, but equally it's hardly going to set the kaggler competition
trembling, 

See below the frequency distribution of the probablities of the predictions. As 
you can see, the model is very accurate when the probability is high, then as you
get lower than around 50% it becomes little more than a guess. Even though this is
stating the obvious somewhat, I found this information to be useful as it does 
demonstrate that the probability value is a good indicator.

#### Frequency distribution of probabilities

<!--html_preserve--><div id="plot_id459901946-container" class="ggvis-output-container">
<div id="plot_id459901946" class="ggvis-output"></div>
<div class="plot-gear-icon">
<nav class="ggvis-control">
<a class="ggvis-dropdown-toggle" title="Controls" onclick="return false;"></a>
<ul class="ggvis-dropdown">
<li>
Renderer: 
<a id="plot_id459901946_renderer_svg" class="ggvis-renderer-button" onclick="return false;" data-plot-id="plot_id459901946" data-renderer="svg">SVG</a>
 | 
<a id="plot_id459901946_renderer_canvas" class="ggvis-renderer-button" onclick="return false;" data-plot-id="plot_id459901946" data-renderer="canvas">Canvas</a>
</li>
<li>
<a id="plot_id459901946_download" class="ggvis-download" data-plot-id="plot_id459901946">Download</a>
</li>
</ul>
</nav>
</div>
</div>
<script type="text/javascript">
var plot_id459901946_spec = {
  "data": [
    {
      "name": ".0/bin1_flat",
      "format": {
        "type": "csv",
        "parse": {
          "x_": "number",
          "count_": "number"
        }
      },
      "values": "\"isCorr\",\"x_\",\"count_\"\n\"Incorrect\",0.05,0\n\"Incorrect\",0.1,1\n\"Incorrect\",0.15,23\n\"Incorrect\",0.2,97\n\"Incorrect\",0.25,137\n\"Incorrect\",0.3,193\n\"Incorrect\",0.35,192\n\"Incorrect\",0.4,174\n\"Incorrect\",0.45,170\n\"Incorrect\",0.5,183\n\"Incorrect\",0.55,168\n\"Incorrect\",0.6,122\n\"Incorrect\",0.65,117\n\"Incorrect\",0.7,102\n\"Incorrect\",0.75,72\n\"Incorrect\",0.8,79\n\"Incorrect\",0.85,88\n\"Incorrect\",0.9,70\n\"Incorrect\",0.95,80\n\"Incorrect\",1,46\n\"Incorrect\",1.05,0\n\"Correct\",0.1,0\n\"Correct\",0.15,5\n\"Correct\",0.2,20\n\"Correct\",0.25,63\n\"Correct\",0.3,77\n\"Correct\",0.35,103\n\"Correct\",0.4,126\n\"Correct\",0.45,146\n\"Correct\",0.5,196\n\"Correct\",0.55,177\n\"Correct\",0.6,209\n\"Correct\",0.65,195\n\"Correct\",0.7,231\n\"Correct\",0.75,258\n\"Correct\",0.8,317\n\"Correct\",0.85,322\n\"Correct\",0.9,496\n\"Correct\",0.95,869\n\"Correct\",1,2023\n\"Correct\",1.05,0"
    },
    {
      "name": ".0/bin1",
      "source": ".0/bin1_flat",
      "transform": [
        {
          "type": "treefacet",
          "keys": [
            "data.isCorr"
          ]
        }
      ]
    },
    {
      "name": "scale/stroke",
      "format": {
        "type": "csv",
        "parse": {}
      },
      "values": "\"domain\"\n\"Incorrect\"\n\"Correct\""
    },
    {
      "name": "scale/x",
      "format": {
        "type": "csv",
        "parse": {
          "domain": "number"
        }
      },
      "values": "\"domain\"\n-6.93889390390723e-18\n1.1"
    },
    {
      "name": "scale/x_rel",
      "format": {
        "type": "csv",
        "parse": {
          "domain": "number"
        }
      },
      "values": "\"domain\"\n0\n1"
    },
    {
      "name": "scale/y",
      "format": {
        "type": "csv",
        "parse": {
          "domain": "number"
        }
      },
      "values": "\"domain\"\n-101.15\n2124.15"
    },
    {
      "name": "scale/y_rel",
      "format": {
        "type": "csv",
        "parse": {
          "domain": "number"
        }
      },
      "values": "\"domain\"\n0\n1"
    }
  ],
  "scales": [
    {
      "name": "stroke",
      "type": "ordinal",
      "domain": {
        "data": "scale/stroke",
        "field": "data.domain"
      },
      "points": true,
      "sort": false,
      "range": "category10"
    },
    {
      "name": "x",
      "domain": {
        "data": "scale/x",
        "field": "data.domain"
      },
      "zero": false,
      "nice": false,
      "clamp": false,
      "range": "width"
    },
    {
      "name": "x_rel",
      "domain": {
        "data": "scale/x_rel",
        "field": "data.domain"
      },
      "range": "width",
      "zero": false,
      "nice": false,
      "clamp": false
    },
    {
      "name": "y",
      "domain": {
        "data": "scale/y",
        "field": "data.domain"
      },
      "zero": false,
      "nice": false,
      "clamp": false,
      "range": "height"
    },
    {
      "name": "y_rel",
      "domain": {
        "data": "scale/y_rel",
        "field": "data.domain"
      },
      "range": "height",
      "zero": false,
      "nice": false,
      "clamp": false
    }
  ],
  "marks": [
    {
      "type": "group",
      "from": {
        "data": ".0/bin1"
      },
      "marks": [
        {
          "type": "line",
          "properties": {
            "update": {
              "stroke": {
                "scale": "stroke",
                "field": "data.isCorr"
              },
              "strokeWidth": {
                "value": 5
              },
              "x": {
                "scale": "x",
                "field": "data.x_"
              },
              "y": {
                "scale": "y",
                "field": "data.count_"
              }
            },
            "ggvis": {
              "data": {
                "value": ".0/bin1"
              }
            }
          }
        }
      ]
    }
  ],
  "legends": [
    {
      "orient": "right",
      "title": "",
      "properties": {
        "legend": {
          "x": {
            "scale": "x_rel",
            "value": 0.1
          },
          "y": {
            "scale": "y_rel",
            "value": 0.9
          }
        }
      },
      "stroke": "stroke"
    }
  ],
  "axes": [
    {
      "type": "x",
      "scale": "x",
      "orient": "bottom",
      "title": "Probability value",
      "format": "%",
      "values": [0.2, 0.4, 0.6, 0.8, 1],
      "layer": "back",
      "grid": true,
      "properties": {
        "grid": {
          "stroke": {
            "value": "white"
          }
        }
      }
    },
    {
      "type": "y",
      "scale": "y",
      "orient": "left",
      "title": "",
      "values": [500, 1000, 1500, 2000],
      "layer": "back",
      "grid": true,
      "properties": {
        "grid": {
          "stroke": {
            "value": "white"
          }
        }
      }
    }
  ],
  "padding": null,
  "ggvis_opts": {
    "keep_aspect": false,
    "resizable": true,
    "padding": {},
    "duration": 250,
    "renderer": "svg",
    "hover_duration": 0,
    "width": "700px",
    "height": "480px"
  },
  "handlers": null
};
ggvis.getPlot("plot_id459901946").parseSpec(plot_id459901946_spec);
</script><!--/html_preserve-->

## Text transformations

My first thoughts to improve this model were to take out some of the less helpful
terms in the bag of words. I didn't do a great deal of this, just a few things 
that looked wrong to me. First - there were a lot of adjectives in the data set
that did not seem to be helpful to my model, but were quite common, so were part of
my model. Examples of this include "fresh", "firm", "frozen" etc. A second category
is two separate words that together means something, but apart, just as two features 
in my bag of words did nothing to help my model. For example, "fish sauce" is a 
dead giveaway for Thai food. But in the bag of words, they appeared as "fish" and
"sauce", which could have been part of any cuisine. The rest were lots of different
words for the same thing. In particular, the difference between ground pepper, chili
peppers and bell peppers needed to be normalized. "red pepper", "pepper", "red chiles"
"chili peppers" needed sorting out. 

I stopped there and wondered if the more I did was starting to hinder my models
as much as they were helping. But I basically came up with five functions that 
were a quick transformation to the text using a regex of some kind to either 
normalize a particular ingredient, remove unnecessary adjectives or join words 
together. In this end, this didn't help my predicitions at all. The way that 
I was choosing the variables in my 'bag of words' model was removing the sparse
terms (so including words that appear on more than x% of recipes). 

## Feature selection

My previous experience working with regression models gave me a nagging sense that
I ought to be doing something more effective in selecting features. In my previous
research, this was done by reading lots of theory and other empirical research to 
carefully select the variables in my model. This was not possible with such a large
data set (and last time I checked there wasn't really a body of research on this 
which ingredients belong to which cuisine!) I saw advice on an online
forum to try some kind of algorithm for selecting features that might make my
model a bit more efficient. I tried on called a singular vector decomposition. 
It took me a while to get my head around how this algorithm works - but basically 
it removes redundant data from your larger and sparser matrix into a smaller and 
denser one. Data might be redundant if variables too closely correlate with one 
another or don't really give much data to indicate anything about the dependent 
variable - so act as noise. As I understand it, this makes your model a bit more 
efficient and a lot smaller. But don't take my word for it - a brief explanation is
here and a longer one is here. 

It takes quite a while to reduce the matrix - I used what is known as a partial 
SVD using the `irlba` package to do this. This package uses the SVD algorithm to
reduce the original matrix to a smaller size and returns a vector that we can
multiply through the original matrix to get it to the right size.


{% highlight r %}
getIrlba <- function(dtm) {
    all.data.svd = irlba(dtm, nv = 400,nu=0)
    as.data.frame(dtm %*% all.data.svd$v)
}
{% endhighlight %}

The updated results? A small improvement. Not massive. But an improvement all the
same. 





