# Introduction

In order to allow a model to learn as much as possible from a set of data, the important features of the data 
usually must be extracted and arranged in such a way that the model can use them to generalize relationships. 
Often there is a long discovery process, in which the data is interrogated manually in order to intuit what 
features to extract and how to present them. Training the model is usually one of the last steps in a lengthy
process. 

In this example I'm going to focus on price series data, for example a multi-year daily stock price time series, 
and I'm going to demonstrate an example of preprocessing the data to extract a few features, in order to prepare
the data to be used to train an LSTM model. 

This simplified example will consist of the following steps: 

1. Read the data 
2. Extract the daily range (high - low) 
3. Remove the trend 
4. Handle outliers 
5. Scale the data 
6. Extract data about the trend, as a new column 
7. Finally, shape the data into the correct shape to be used as input for a tensorflow LSTM model

Prerequisites: 
- python 3
- scikit-learn 
- pandas 
- jupyter notebook (or jupyter lab) 

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

... and will be in the 3-dimensional array shape that a tensorflow LSTM model expects, split into 
training, evaluation, and testing sets. 

## Reading the Data 

The data is read from a file downloaded from the free historical stock data at Yahoo Finance; the columns 
are OHLC, plus Adjusted Close and Volume. Feel free to use any Yahoo historical stock price data, but the 
exact data file that I used is here: 
[https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/data/prices-d.csv](https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/data/prices-d.csv)

```
df = pd.read_csv("data/prices-d.csv", index_col=0)
df.head()
```

The only column that we won't be touching at all is Volume, so I'll just remove that straightaway. 
Also we don't need 'Close', as we'll use 'Adj Close' instead, as it's better for most purposes.
The other columns will be used to extract useful features, and then afterwards those source columns may be 
discarded from the DataFrame. 

```
df.pop("Volume")
df.pop("Close")
```

### Capture the Range 

The absolute values of the Open, High, and Low won't be useful to us. The daily range as a percentage of 
something (the Open, or previous day's Close for example) could be useful though, so we should extract 
what's useful, and get rid of what's not. 

```
df["Range"] = (df["High"] - df["Low"]) / df["Open"]
```

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
