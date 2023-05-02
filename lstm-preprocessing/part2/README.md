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

![image](https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/part2/images/retrend/trendlines2.png)

![image](https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/part2/images/retrend/trendpoints2.png)

![image](https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/part2/images/retrend/trendlines3.png)

![image](https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/part2/images/retrend/trendpoints3.png)

Then this data will be added as a new column to the DataFrame, called 'Trend'. Note that the data is already normalized between 0 and 1, so it doesn't require scaling. And there's no need to handle outliers, because there are none.

```
trend = extract_trend(df['Adj Close'], 100)
df['Trend'] = trend.as_boolean(df['Adj Close'][0])
print(len(trend.as_boolean(df['Adj Close'][0])))

# remove Adj Close, as we have extracted what we need from it
df.pop("Adj Close")
df.head()
```
![image](https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/part2/images/retrend/trendcol.png)

## Shaping the Data

Finally, we have 3 columns (or features): Range, Change, and Trend. 

Let's assume that Trend is what we want the model to predict.

The input for a keras LSTM requires a three dimensional array with the shape: 
(s, t, f)

s = samples: the number of samples in the data set (i.e. the number of rows of data) 
t = timesteps: the number of timesteps to be input for each sample (also sometimes called the 'lag')
f = features: the number of distinct features to be considered; in this case, 3 (Range, Change, Trend)

An LSTM can predict multiple output features, and can do so with a variable offset and width. But just to keep things simple, we'll assume for this example that the output offset is 1, the LSTM will predict only one output feature (Change), and it will predict for only one timestep: the next day's Change.

Note also that the output feature need not be one of the input features as well. In this case, Change is present in both the input and the output.

X represents the input values. 
y represents the predicted or expected values.

**X: Range(t[-10:0]), Change(t[-10:0]), Trend(t[-10:0])
y: Change (t+1)**

**Steps:**
1. Extract the 'y' values, or the values to be predicted. This is supervised learning, so these are all the 'correct' answers for training.
2. Window the appropriate number of timesteps for each input
3. Add one example of each feature, to each window

Because the LSTM keeps a memory of more recent inputs, data is fed into it in a forward walking window the size of a predetermined number of timesteps. Each discrete input contains multiple overlapping windows, and each window contains one example of each feature. It's easier to explain with an example:

The raw input data has 10 rows of 2 features each: f1, f2. It looks like this:

```
_df1 = pd.DataFrame()
_df1['f1'] = ['r0f1', 'r1f1', 'r2f1', 'r3f1', 'r4f1', 'r5f1', 'r6f1', 'r7f1', 'r8f1'] 
_df1['f2'] = ['r0f2', 'r1f2', 'r2f2', 'r3f2', 'r4f2', 'r5f2', 'r6f2', 'r7f2', 'r8f2'] 
_df1.head(9)
```

![image](https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/part2/images/shape/table1.png)

So the outermost dimension of the 3-dimensional input array will have 10 elements. Each of those elements will be an array, so let's create this to begin with:

[ [] [] [] [] [] [] [] [] [] [] ]

It's an array containing 10 empty arrays.

How many timesteps? Let's say 3. So each of those empty arrays will have 3 arrays inside of them. Each of those innermost arrays will contain the 2 features.

To simplify, first create an array of 3-element arrays, where each element of the inner array represents one row. Since this is daily data, we'll call row 0 d0, row 1 is d1, and so on.

The function to get the X values from the data set, shaped correctly as a 3-dimensional array in the form (samples, timesteps, features):

![image](https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/part2/images/shape/xy2.png)

There are missing values, because in the beginning two records, there is a lack of previous data for t-2, and t-1, and at the end it's impossible to make a prediction because we don't have the future y value; this is expected. If we remove those missing-data rows then we are left with:

![image](https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/part2/images/shape/xy3.png)

This function will do the necessary shaping and transforming for X, and will output X shifted and shaped correctly as a 3-dimensional array:

```
# extract X with the given number of timesteps
# df: the DataFrame
# ntimesteps: number of timesteps
#
def extract_X(df: pd.DataFrame, ntimesteps: int): 
    features = len(df.columns)
    X = list()
    
    #offset for timesteps
    offsets = list()
    for i in range (ntimesteps, 0, -1): 
        offsets.append(df.shift(i))
        
    #combine timestep columns into rows 
    combined = pd.concat(offsets, axis=1)
    combined = combined.tail(-ntimesteps) 
    combined.drop(combined.tail(1).index, inplace=True)
    
    #reshape each row (timesteps, features)
    for i in range(len(combined)): 
        row = combined.iloc[i].to_numpy()
        xrow = list()
        for n in range(ntimesteps): 
            xrow.append(row[n*features:(n*features)+features])
        X.append(xrow)
    
    #return as numpy array
    return np.array(X)
 ```
 
 And the function to get the y values from the dataset, shaped correctly (as a 1 dimensional array):
 
 ```
 # extract y column (the col to be predicted)
# df: the DataFrame
# col_name: the name of the column to be predicted 
# ntimesteps: number of timesteps
#
def extract_y(df: pd.DataFrame, col_name: str, ntimesteps: int): 
    shifted = df.shift(-1)
    shifted = shifted.head(-2)
    shifted = shifted.tail(-(ntimesteps-1))
    return shifted[col_name].values
 ```
 
 Replace each day (row) with an array containing the two features of that day (row). So d0 becomes the two-element array [r0f1, r0f2].
 
![image](https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/part2/images/shape/rofl1.png)
 
 And the three lines to call these methods on the dataset, to get X and y values:
 
 ```
 _y1 = extract_y(_df1, 'f2', 3)
_x1 = extract_X(_df1, 3)
print(_x1)
```

The row numbers are sequential in each column going from top to bottom, and ordinal from left to right. That's the input format. Since the first two rows contain nulls, we'd remove them. So we end up with the number of rows being r = (r - (timesteps - 1)).

Now the y values are just a scalar array of feature 2 from each row, but shifted back 1.

![image](https://github.com/jrkosinski/articles/blob/main/lstm-preprocessing/part2/images/shape/rofl2.png)

```
class DataSet:
    def __init__(self, X, y): 
        if X.ndim != 3: 
            raise Exception("Expected a 3-dimensional array for X")
        if y.ndim != 1: 
            raise Exception("Expected a 1-dimensional array for y")
        if len(X) != len(y): 
            raise Exception("Length of X and y must be the same")
        
        self.X = X
        self.y = y
    
    # pct% of the dataset will be split off and returned as a new DataSet
    def split(self, pct:float): 
        count = int(self.size * pct)
        new_dataset = DataSet(self.X[:count], self.y[:count])
        self.X = self.X[:-count]
        self.y = self.y[:-count]
        return new_dataset
        
    @property
    def size(self): 
        return len(self.X)
 ```
 
 ```
 timesteps = 10
X = extract_X(df, timesteps)
y = extract_y(df, 'Trend', timesteps)
```

Finally we can take all of the scaled, processed, shaped data as a whole and split it into training, validation, and testing sets with an approximately 70–20–10 split:

```
train = DataSet(X, y)
val = train.split(0.3)
test = val.split(0.3)

print(f'train set has {train.size} samples')
print(f'val set has {val.size} samples')
print(f'test set has {test.size} samples')
```

train set has 2240 samples
val set has 672 samples
test set has 288 samples

```
print('train X shape:', train.X.shape)
print('val X shape', val.X.shape)
print('test X shape:', test.X.shape)
```

train X shape: (2240, 10, 4)
val X shape (672, 10, 4)
test X shape: (288, 10, 4)
And that's the input shape for a tensorflow LSTM.

## Conclusion

So we have had, from Part 1 to now, 
- Price series data detrended 
- Price series data with daily range extracted 
- Price series data normalized, and outliers removed
- The long-term trend extracted from the series 
- The final data set shaped correctly for input into a keras LSTM model
- Finally, the finished data is split into training, validation, and testing sets

And the purpose was to demonstrate just a few of infinite ways in which time/price series data can be pre-processed before being used in a prediction model.

**Q: Is it really practical to predict Trend in this way? Will a model trained with this data successfully predict something useful?**

A: No! Or probably not. This is not meant to be a practical example of anything except for different ways of preparing and pre-processing data for input to a model, particularly a keras LSTM model. I haven't actually run this through a model and I don't intend to.

**Q: What is the point of extracting the trend from the price data, and then re-introducing it in a different form?**

A: The trend was implicit in the price, and in the Change column, and still is even after the transformations. It's implicit, but not prominent enough to be useful. It would be very very difficult for an model to extract that feature (the trend) by itself, and models don't have infinite processing power. Part of the discovery process is trying different things, bringing different features to prominence and seeing how the model performs on them. One can't expect the model to do all the work itself.

**Q: If the model can't extract important features from the raw data by itself, what is the model for?**

A: The model can extract important features, but its power to do so is very much not unlimited, and it needs due amounts of help. Normally, the model's just doing the last but very important steps in a process that could be done by non-ML human-powered statistical analysis, but would possibly take an inordinately long time or large amount of effort. Unless you have access to model networks that are under lock and key at the NSA (joking here), you need to have some idea of what you want the model to do, and help it to get started. 

The analogy here is teaching mathematics to a young child. If you put a kid in a library full of math textbooks, the kid is very unlikely to learn multiplication despite the fact that all of the necessary information is available. The information must be taken out, molded into examples and stories, and fed in. And it's possible that one day, that kid will discover new techniques or proofs that advance the field of mathematics.
