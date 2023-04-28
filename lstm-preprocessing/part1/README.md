# Preparing and Shaping Timeseries Data for Keras LSTM Input: Part One

It's been said many times that the real key in machine learning is in how the data is processed, rather than in the model architecture. 
Clearly both are important, but the importance of preprocessing the data may be sometimes underestimated. 

In order to allow a model to learn as much as possible from a set of data, the important features of the data 
need to be extracted and arranged in such a way that the model can use them to generalize relationships. 
Often there is a long discovery process, in which the data is interrogated manually in order to intuit what 
features to extract and how to present them. Training the model is usually one of the last steps in a lengthy
process. 

In this example I'm going to focus on price series data, for example a multi-year daily stock price time series, 
and I'm going to demonstrate an example of preprocessing the data to extract a few features, in order to prepare
the data to be used to train a keras LSTM model. 

This simplified example will consist of the following steps: 

Part 1: 

1. Read the data 
2. Extract the daily range (high - low) 
3. Remove the trend 
4. Handle outliers 
5. Scale the data 

Part 2: 

7. Extract data about the trend, as a new column 
8. Finally, shape the data into the correct shape to be used as input for a keras LSTM model

This article is available in jupyter notebook form, for both [part 1](https://github.com/jrkosinski/articles/tree/main/lstm-preprocessing/part1) and [part 2](https://github.com/jrkosinski/articles/tree/main/lstm-preprocessing/part2), here: 

[https://github.com/jrkosinski/articles/tree/main/lstm-preprocessing](https://github.com/jrkosinski/articles/tree/main/lstm-preprocessing)

Prerequisites: 
- python 3
- scikit-learn 
- pandas 
- jupyter notebook (or jupyter lab) 

Keras and tensorflow are not required for this example, as it's only about preprocessing the data prior to training a model; there is 
no actual model involved in this example. 

The data comes from Yahoo Finance historical data, and is availbale at 

The data comes with the following columns: 
- Open
- High
- Low
- Close 
- Adjusted Close 
- Volume 

At the end of the example, the data will have been transformed, with 3 scaled and normalized columns: 
- Range
- Change
- Trend 

... and will be in the 3-dimensional array shape that a keras LSTM model expects, split into 
training, evaluation, and testing sets. 

In part one, this example will extract Range and Change from the timeseries data, remove the outliers, and scale the data between 0 and 1. 
In [part two](../part2/), the example will take the result of that, retrend the data, and shape it appropriately for input to a keras LSTM model.

## Reading the Data 

The data is read from a file downloaded from the free historical stock data at Yahoo Finance; the columns 
are OHLC, plus Adjusted Close and Volume. Feel free to use any Yahoo historical stock price data, but the 
exact data file that I used is here: 
[https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/data/prices-d.csv](https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/data/prices-d.csv)

```
df = pd.read_csv("data/prices-d.csv", index_col=0)
```
![data](images/1.png)

The only column that we won't be touching at all is Volume, so I'll just remove that straightaway. 
Also we don't need 'Close', as we'll use 'Adj Close' instead, as the continuous series is better for most purposes.
The other columns will be used to extract useful features, and then afterwards those source columns may be 
discarded from the DataFrame. 

```
df.pop("Volume")
df.pop("Close")
```

## Capture the Range 

The absolute values of the Open, High, and Low won't be useful to us. The daily range as a percentage of 
something (the Open, or previous day's Close for example) could be useful though, so we should extract 
what's useful, and get rid of what's not. 

```
df["Range"] = (df["High"] - df["Low"]) / df["Open"]
```
![plot range](images/range/range_added.png)

The single line of code above that extracts the daily range is possible thanks to the non-native Python 
library pandas. In case you aren't accustomed to using pandas (and just to demonstrate what that line actually does) 
it would be as if I had looped through the data and done this: 

```
df['Range'] = 0 #add new column 
for i in range(len(df)): 
    df['Range'][i] = (df["High"][i] - df["Low"][i]) / df["Open"][i]
```

Just to show what the Range column looks like, I will plot it. 

```
df['Range'].plot()
```
![plot range](images/range/plotrange_1.png)

Just a few comments here; you can visually see a few things: 
- there is no discernable strong trend 
- the distribution is noticeably skewed right, with extreme positive outliers 
- the range of the data is not neatly between 0 and 1

The lack of trend is a good thing, we want that to feed into the model. The right-skew and the scale, we will 
fix in later steps. If you like to get empirical, we can show the low trendiness of the series using augmented Dickey-Fuller or 
some other metric. 

```
print('p-value: %f' % adfuller(df['Range'])[1])
```
![plot range](images/range/pvalue.png)

Here I've plotted the distribution to better show the skewness of the data, though you can see it plainly 
enough in the previous plot. Removing outliers should make the data more balanced, so I will do that in a later 
step. 

```
df['Range'].plot(kind='kde')
```
![plot range](images/range/rangedist.png)

Now that we've extracted the daily range from the Open, High, and Low columns, we don't need those anymore, 
so I'll just remove them. The information that we needed is now in the Range column. 

```
# remove extra columns 
df.pop("Open")
df.pop("High")
df.pop("Low")
```
![two cols](images/range/2cols.png)

## Detrending Price (Capture Change)

### Absolute Change 

A data series may exhibit trend, and it may exhibit seasonality. Multi-year stock price data is less likely to show 
seasonality, but very likely to show a strong persistent trend. The problem with trended data (especially inflation-affected
financial asset data, which tends to grow exponentially with inflation) is that it smashes early data into oblivion, making 
it nearly invisible to the model trying to generalize something from it. This is why absolute price is 
almost never fed into a model without being heavily processed.

Now for the closing price ('Adj Close' column), again no one cares about the absolute price from day to day, 
what one cares about is the change in price from day to day. Pandas lets us acheive that with the following 
single line: 

```
df['Abs Change'] = df["Adj Close"].diff()
```

But the main problem is evident when we plot this over time. We can see that as the price rose over the years, the 
average daily change also increased, naturally. This is not ideal data to feed into a model, because 
(as you can see) earlier values will be de-emphasized to the point of nearly being ignored, whereas later 
data points will be overemphasized in relation. Since we would like the model to be able to glean meaningful 
data from the entire dataset, this is less than ideal. The plot below shows data that is likely to be 
difficult for a model to extract generalizations from. 

```
df['Abs Change'].plot()
```
![plot_abschange](images/change/plot_abschange.png)

### Percentage Change

Instead, the percentage change is what we want. It's less likely to be skewed or trended, and we can see this visually
by plotting. 

```
#first remove Abs Change, as we don't need it 
df.pop("Abs Change")

df['Change'] = df["Adj Close"].pct_change()
df['Change'].plot()
```
![plot_pct_change](images/change/plot_pct_change.png) 

![nan](images/change/nan.png)

Note that the very first value for the Pct Change column is a NaN. The reason is that to get this column, each 
value in the source column was compared to its previous timestep, and the first record has no previous to which 
to compare.

The NaN can be removed reasonably by either basing the first change off of the Open 
(instead of the previous step's Close), or just by simply removing the first row. I'll just remove the first row. 

```
print('len before:', len(df))
df = df. tail(-1) 
print('len after:', len(df))
df.head()
```

## Outliers 

The model is best able to extract generalizations from the data if most of the data falls within a normal 
range. Outliers tend to skew the data such that some values (which may be important) will be almost ignored, 
whereas others will be overemphasized. 

Just to clarify I'm not talking here about outliers that may reflect mistakes in the data collection process 
necessarily (bad data samples can often just be discarded), but simply events of unusual magnitude. For 
example, price data that contains a swan event such as a major flash 
crash that is many times larger than the normal daily move may de-emphasize the magnitude of all of the others 
days' data. This can cause a model trained on data that contains the swan event to come up with very different results 
compared to the same model trained on data that did not contain the event. That's not ideal, because it 
indicates that something is interfering with the model's ability to generalize from the available data.

Take another peek at the Change column before handling outliers. Note that just by visual inspection, it's 
clear that most of the data falls into a very small percentage of the full range of values. That should be 
corrected so that at least more than 50% of the data falls within more than 50% of the range (just ballpark 
figures here, there is no real rule of thumb. It would depend on the goals of the data, and your idea of 
what the ideal 'balance' of data is for your situation; but we can see that the data here is clearly not 
well balanced). 

```
df['Change'].plot()
```
![plot_pct_change](images/change/plot_pct_change.png)

### Function to Squash Outliers

I don't want to remove the rows that contain outliers, because that would be removing real data that we want 
to give to the model. I don't 
want to zero the values either as that would skew the data in a different direction. Instead I would like to 
'squash' the values to within a reasonable range, where outliers >=n will be treated the same as values 
that are equal to n.

```
def squash_col_outliers(
    df: pd.DataFrame, 
    col_name: str, 
    min_quantile: float =0.01, 
    max_quantile:float =0.99
): 
    q_lo = df[col_name].quantile(min_quantile)
    q_hi  = df[col_name].quantile(max_quantile)
    
    df.loc[df[col_name] >= q_hi, col_name] = q_hi
    df.loc[df[col_name] <= q_lo, col_name] = q_lo
    return df

```

Min and Max before squashing:
```
print('MIN:', df['Change'].min())
print('MAX:', df['Change'].max())
```
![minmax change 1](images/outliers/minmax_change_1.png)

### Squash Outliers in Change
```
df = squash_col_outliers(df, 'Change')
```

Min and Max after squashing:
```
print(df['Change'].max())
print(df['Change'].min())
```
![minmax change 2](images/outliers/minmax_change_2.png)

Now we can visually see in the plot of Change that there's a more balanced distribution of values, that will be 
more healthy for the model to digest. Again, there is no formula for the perfect balance, and this is part 
of a discovery process in which we'd like to get enough information to intuit a good enough rule, or what is 
closer to an ideal. 

```
df['Change'].plot()
```
![plot change](images/outliers/plot_change.png)

### Squash Outliers in Range

The shape of the Range data is a bit different, so I'm going to do basically the same thing, but I'm going 
to pass different values for the upper and lower limits, so that the left of the distribution will be less 
affected by squashing, and the right of the distribution will be more affected (which is where it's needed). 
I can do that by just passing lower values (lower than the default) for both _min_quantile_ and _max_quantile_. 
That will cause the function to squash more on the top and less (or not at all, in this case) on the bottom. 

```
df['Range'].plot()
```
![plot range_before](images/range/plotrange_1.png)

```
df = squash_col_outliers(df, 'Range', min_quantile=0.0, max_quantile=0.97)
```

And now, we likewise see a more even distribution of values. 

```
df['Range'].plot()
```
![plot range](images/outliers/plot_range.png)


## Scaling

Scaling input data between 0 and 1 is conventional when preparing inputs to LSTM or other types of 
models. While not strictly necessary, and there are cases in which it's not advisable, it is generally considered good 
practice. 

This function uses MinMaxScaler from scikit-learn package to fit the values of a given column between 0 and 1 
(or any given values) and replaces the original column in the DataFrame with the new data. 

```
def scale_col_values(
    df: pd.DataFrame, 
    col_name:str, 
    min_value:float=0, 
    max_value:float=1
): 
    values = df[col_name].values.reshape(-1, 1)
    scaler = MinMaxScaler(feature_range=(min_value, max_value))
    scaled_values = scaler.fit_transform(values)
    df[col_name] = scaled_values.transpose()[0]
    return df
    
```

Check the min and max of the Change column before scaling. 

```
print(df['Change'].min())
print(df['Change'].max())
```
![minmax_change](images/scaling/minmax_change_1.png)

```
df = scale_col_values(df, 'Change')
```

Check that it's been changed by the scaling process. 
```
print(df['Change'].min())
print(df['Change'].max())
```
![minmax_change](images/scaling/minmax_change_2.png)

And very importantly, note that the shape of the data has not changed, it's only been rescaled. The plot 
from before looks the same as after, except for the scale of the y axis. 

```
df['Change'].plot()
```
![plot_change](images/scaling/plot_change.png)

Scaling of Range is exactly the same. 

```
df = scale_col_values(df, 'Range')
```

And likewise, the scale has been the only thing changed. 

```
df['Range'].plot()
```
![plot_range](images/scaling/plot_range.png)


## Conclusion of Part One
So now the Range has been extracted and added to the dataset, the % daily Change has been extracted and added to the dataset, outliers in 
both columns have been handled, and the data has been scaled. All other columns have been removed, except for Adj Close; this will be used in 
[Part Two](../part2/) to re-extract trend data. 
