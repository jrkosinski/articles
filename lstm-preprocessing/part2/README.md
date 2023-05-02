# Preparing and Shaping Timeseries Data for Keras LSTM Input: Part Two

It's often said that successful machine learning comes more from how the data is processed, than the model architecture. Clearly both are important, but the importance of pre-processing the data might be sometimes underestimated.

In order to allow a model to learn as much as possible from a set of data, the important features of the data need to be extracted and arranged in such a way that the model can use them to generalize relationships. Often there is a long discovery process, in which the data is interrogated manually in order to intuit what features to extract and how to present them. Training the model is usually one of the last steps in a lengthy process.

In this example I'm going to focus on price series data, for example a multi-year daily stock price time series, and I'm going to demonstrate an example of preprocessing the data to extract a few features, in order to prepare the data to be used to train a keras LSTM model.

**Part 1:**

1. Read the data 
2. Extract the daily range (high - low) 
3. Remove the trend 
4. Handle outliers 
5. Scale the data 

**Part 2:**

7. Extract data about the trend, as a new column 
8. Finally, shape the data into the correct shape to be used as input for a keras LSTM model

This article is available in jupyter notebook form, for both [part 1](https://github.com/jrkosinski/articles/tree/main/lstm-preprocessing/part1) and [part 2](https://github.com/jrkosinski/articles/tree/main/lstm-preprocessing/part2), here: 

And in complete form with minimal comments:
[https://github.com/jrkosinski/articles/tree/main/lstm-preprocessing/complete.ipynb](https://github.com/jrkosinski/articles/tree/main/lstm-preprocessing/complete.ipynb)

## Retrending
Earlier in the process, we 'removed' the trend from the data by extracting the daily % change. The trend is of course still implicit in the % daily change, but it's no longer prominent. However, the trend can be an important feature of the data, and for some purposes one may want to extract it as well.

There are many ways to extract the trend from a time series. One might use arithmetic decomposition, or one might be inclined to use a simple MA or EMA, but the problem (may be a problem, depending on what you're doing) is that moving averages tend to lag. To accurately capture the exact high and low points based on a certain given granularity, I created a function to discern non-seasonal (or quasi-seasonal) highs and lows, and draw trendlines between them. For this example, I'm going to create then, then extract from it a range of values in which:
0: indicates the trend turns downwards at this point (it's a high point) 
1: indicates the trend turns upwards at this point (it's a low point)
0.5: indicates that the current trend continues

This technique may not be good for de-noisifying a series, but it's good for extracting the pivot points. Below is a demonstration of it, with the trendlines overlaid on the original price series, over a few small segments of the series (the small segments are more convenient to view).

Note that passing a smaller value for the period parameter will capture more of the price spikes, and passing a larger value will tend to capture fewer of them.

The _extract_trend_ function and related code is too big to comfortably put into a code block, but can be found here:
[https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/lib/Trend.py](https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/lib/Trend.py)

The following code uses the extract_trend function to get and display the trend from the first 450 data points in the series, 150 data points at a time (that's just to make what it's doing more clear and visible)

```
step_size = 150
range_size = 10

for i in range(3): 
    # extract trend from a subset of the price series 
    series = df['Adj Close'][:i*step_size+step_size]
    trend = extract_trend(series, range_size)
    
    # scatterplot: highs are red, lows are green 
    highs_x, highs_y = trend.as_scatterplot('hi')
    lows_x, lows_y = trend.as_scatterplot('lo')

    plt.scatter(highs_x, highs_y, color='red')
    plt.scatter(lows_x, lows_y, color='green')
    plt.plot(series)
    
    # overlay trend lines 
    plt.plot(trend.as_price_series(series[0]))
    plt.show()
    
    # show boolean 
    plt.plot(trend.as_boolean(series[0]))
    plt.show()
    range_size *= 2
```

