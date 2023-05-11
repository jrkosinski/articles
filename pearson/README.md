# Pearson's Coefficient

## What is Pearson's Coefficient? 

Pearson's Correlational Coefficient is a measure of the correlation between two variables, expressed in terms of the covariance between the two variables and their standard deviations. Also known as Pearson's Correlation or Pearson's r, it's a very common way to calculate the correlation between two variables. More specifically, it's the ratio of the covariance of the two variables (_X_ and _Y_) and the product of the standard deviation of _X_ and the standard deviation of _Y_. The formula to express that is: 

$$  \rho X,Y = covar(X,Y) /  \sigma X \sigma Y $$

Where 
- $\rho is Pearson's correlation, 
- _covar_ is the covariance between X and Y
- $\sigma is standard deviation 

The Pearson's coefficient for X and Y is equal to the covariance of X and Y, divided by the product of $\sigma X$ and $\sigma Y$ (where $\sigma$ is standard deviation). Covariance is a measure of the co-variability between X and Y in terms of their expected value.

A Pearson's value of 1 indicates perfect positive correlation between X and Y. A Pearson's value of -1 indicates perfect negative correlation. A Pearson's value of 0 indicates no correlation. 

As an example, the series X=[1,2,3] and Y=[1,2,3] should be perfectly correlated, and should have Pearson's ($\rho =  1$). Likewise, X=[1,2,3] and Y=[2,3,4] should also be perfectly correlated. 

If X and Y are both completely random series, we'd expect Pearson's to be very close to 0 ($\rho =  0$). 

X=[3,2,1] and Y=[1,2,3] should have $\rho =  -1$, as they're perfectly negatively correlated. 

Pearson's Correlation is named after early 20th century mathematician Karl Pearson, or possibly after the cook from RDR2. 

![pearson](https://github.com/jrkosinski/articles/blob/main/pearson/images/pearson.png)


## What is the Pearson Coefficient Good For? 

The Pearson correlation is used to help answer the question: are the variables X and Y correlated, to what extent, 
and is that correlation negative or positive? The value can be used to pre-select certain features for further 
processing or for use in a machine learning algorithm. 

Pearson is useful in determining whether or not two series show either a direct or inverse correlation; where the 
term 'correlation' is used in a strict sense, meaning a very direct sort of correlation. In a direct correlation, 
x increases as y increases, and in an inverse correlation, x increases as y decreases (and vice versa). 

I will demonstrate, using some randomly generated and some deliberately constructed data series. 

I'll start with a function to calculate Pearson's coefficient for any two series, using numpy's implementation 
of pearson. Pandas has its own implementation, there are many other implementations, we can assume that they 
are all doing the same thing. 
```
def calc_pearson(series1, series2) -> float: 
    '''Calculates Pearson's correlation''' 
    pearson = np.corrcoef(series1, series2)
    return pearson[0][1]
```

And these utility functions will help to examine the results. 
```
def plot_series(s1, s2): 
    '''Plots two series in one graph'''
    plt.plot(s1)
    plt.plot(s2)
    
def show_series_correlation(s1, s2) -> float: 
    '''Calculates, prints, and returns Pearson's R'''
    r = calc_pearson(s1, s2)
    print(f'R = {r}')
    return r
```

As stated, any two random series that are sufficiently long enough should have a Pearson's correlation (I'll refer 
to as _R_) of close to 0. As series _x_ and _y_ get longer, the _R_ of _x_ and _y_ should convert to 0. To demonstrate, I'll add a 
function to create a random series. 
```
def random_series(length: int): 
    '''Generate a pandas Series of random values between 0 and 1, of the given length. 
    Returns: pandas Series'''
    output = list()
    for i in range(length): output.append(random())
    return pd.Series(output)
    
#show the correlation between two randomly generated series
series_len = 100000
for i in range (20): 
    show_series_correlation(random_series(series_len), random_series(series_len))
```

![figure 1](https://github.com/jrkosinski/articles/blob/main/pearson/images/nearzero.png)

And as stated, two exactly identical arrays should show an _R_ of exactly 1. 
To demonstrate:

```
series1 = random_series(100)
series2 = series1

# this should be 1.0
show_series_correlation(series1, series2)
```

![figure 2](https://github.com/jrkosinski/articles/blob/main/pearson/images/R1.png)

To demonstrate perfect inverse correlation, first create a random series, then create a copy 
which is an inverse of the first. 

```
def mirrored_series(length: int): 
    '''Creates a randomized series of the given length with random values between 0 and 1, and a mirror image 
    of that series with a perfect inverse correlation to the first, and values between 0 and -1.
    Returns: tuple (pandas.Series, pandas.Series)'''
    s1 = random_series(length)
    s2 = s1 * -1
    return s1, s2
    
series1, series2 = mirrored_series(100)
plot_series(series1, series2)
```

![figure 3](https://github.com/jrkosinski/articles/blob/main/pearson/images/mirror.png)

We expect the result (_R_) to be equal to -1

```show_series_correlation(series1, series2)```

![figure 4](https://github.com/jrkosinski/articles/blob/main/pearson/images/rneg.png)

### Imperfect Correlation 

To demonstrate a strong correlation that is not quite perfect, create a copy of an array but slightly 
jiggle the values a bit. 

```
def correlated_series(length:int, variance: float): 
    '''Creates a randomized series of the given length with random values between 0 and 1, and a correlated 
    series. 

    length: length of the two series to return 
    variance: value between 0 and 1; 0 indicates perfect correlation, 1 indicates uncorrelated.
    Returns: tuple (pandas.Series, pandas.Series)'''
    s1 = random_series(length)
    s2 = list()
    
    for i in range(length): 
        val = s1[i] 
        r = random()
        if (r <= variance): 
            val = random()
        s2.append(val)
    return s1, pd.Series(s2)
    
series1, series2 = correlated_series(100, .3)
plot_series(series1, series2)
```

![figure 5](https://github.com/jrkosinski/articles/blob/main/pearson/images/correlated.png)

As the variance (the amount by which the values of the series are jiggled to make them unequal) increases, 
it should be expected that the _R_ for the two series will drop accordingly. See: 

```
variance = 0.1
correlation = list()
for i in range(0, 11): 
    series1, series2 = correlated_series(1000, i * variance)
    p = calc_pearson(series1, series2)
    correlation.append(p)
    print(f'p with variance of {i}: {p}')
    
plt.plot(correlation)
```

![figure 6](https://github.com/jrkosinski/articles/blob/main/pearson/images/fallingR.png)

### Vertical Lag 

We should expect Pearson to consider a series to be perfectly correlated to another series even if there 
is considerable vertical distance between corresponding values of the series, because it isn't the actual 
values that are correlated to one another, but the relative change in those values. To demonstrate, create 
two series, but change all of the values of series 2 by a constant amount. 

```
series1 = random_series(100)
series2 = series1 + 3

plot_series(series1, series2)
```

![figure 7](https://github.com/jrkosinski/articles/blob/main/pearson/images/vlag.png)

And though the values of the two series are far apart from one another, expect the correlation to still be equal 
to 1.

```show_series_correlation(series1, series2)```

![figure 8](https://github.com/jrkosinski/articles/blob/main/pearson/images/Rvlag.png)

It should be so with negative correlation as well. 

```
series1, series2 = mirrored_series(100)
series2 = series2 + 3

plot_series(series1, series2)

# expect this to be -1.0
show_series_correlation(series1, series2)
```

![figure 9](https://github.com/jrkosinski/articles/blob/main/pearson/images/rneg2.png)

## What is Pearson Correlation _not_ Good For? 

Pearson is a very simple measure, taken from corresponding values of _n_ only, and as such it should be expected 
to have strict limitations. It won't be able to find more esoteric forms of correlation.

### Horizontal Lag 

Imagine that we have two perfectly correlated (or identical) series _x_ and _y), but _y_ is offset from _x_ 
by a small amount on the horizontal axis. Just slide _y_ over to the right by one or two steps on the 
horizontal axis. Are _x_ and _y_ correlated? Will the Pearson measure find the correlation? 

```
def shift_series(s1, offset): 
    '''Shifts the given series to create a new shifted series
    Returns: both series as tuple (original, new)
    '''
    # add horizontal offset 
    s2 = s1.shift(offset).dropna()
    
    # adjust s1 for length of missing values in s2
    if (offset > 0): 
        s1 = s1[offset:]
    elif (offset < 0):
        s1 = s1[:offset]
        
    return (s1, s2)

def offset_series(length: int, v_offset: float=0.0, h_offset:int=0): 
    '''Creates a random series with of the specified length with random values between 0 and 1, and a second 
    series that is a copy of the first, but with the specified optional horizontal and vertical offsets. 

    length: maximum length of the two series to return; actual length will be (length - abs(h_offset))
    v_offset: vertical offset to be added to each value of the second series, can be negative or positive
    h_offset: horizontal offset or lag; can be negative or positive 
    Returns: tuple (pandas.Series, pandas.Series)
    '''
    s1 = random_series(length)
    
    # add horizontal offset 
    s1, s2 = shift_series(s1, h_offset)
        
    # add vertical offset 
    s2 = s2 + v_offset
    return s1, s2
    
series1, series2 = offset_series(100, h_offset = -3)
plot_series(series1, series2)
```

![figure 10](https://github.com/jrkosinski/articles/blob/main/pearson/images/hoffset.png)

_R_ isn't noticeably different from that of two random series, even though the horizontal offset is only one. 

```show_series_correlation(series1, series2)```

![figure 11](https://github.com/jrkosinski/articles/blob/main/pearson/images/uncorrelated.png)

```
correlation = list()
for i in range(0, 100): 
    series1, series2 = offset_series(1000, h_offset = i)
    correlation.append(calc_pearson(series1, series2))
```

This will show that the amount of offset doesn't matter at all. Knowing the way in which
Pearson's is calculated, this makes sense and is to be expected. When comparing the offset series, it's 
really just comparing essentially random values. The plot will show that _R_ when the offset is 1 is only 
superficially different from the _R_ when the offset is 10. 

```
plt.plot(correlation)
```

![figure 12](https://github.com/jrkosinski/articles/blob/main/pearson/images/corr_hoffset.png)

Just a side note: if the data exhibits a trend, and if the offset is small enough, some of the correlation 
could still 'shine through'. Remember that Pearson is comparing only _n_ to _n_ for the two series, and each 
comparison is discrete so anything adjacent will just be ignored. But strongly trended data can break through 
that a bit, by having a similar change for adjacent values of _n_. Let's try to show that: 

```
def trended_series(length:int, max_trend_len:int=10): 
    output = list()
    index = 0
    value = random()
    trend_direction = -1
    
    while (index < length): 
        # new trend
        trend_len = randint(1, max_trend_len+1)
        trend_direction *= -1
        slope = random() * trend_direction
        
        if (index + trend_len >= length): 
            trend_len = length - index
            
        for i in range(trend_len): 
            value += slope
            output.append(value)
            index += 1
        
    return pd.Series(output)
```

```
trended = trended_series(100, 10)
trended, trend_shift = shift_series(trended, 1)

plot_series(trended, trend_shift)
```

![figure 13](https://github.com/jrkosinski/articles/blob/main/pearson/images/trend_shift.png)

But it should be also expected that as the offset grows in relation to the max trend length - and especially 
as the offset becomes greater than the max trend length - the observed _R_ correlation breaks down. 

```
trended = trended_series(100, 2)
correlation = list()

for i in range(1, 10): 
    trended, trend_shift = shift_series(trended, i)
    correlation.append(show_series_correlation(trended, trend_shift))
    
plt.plot(correlation)
```

![figure 14](https://github.com/jrkosinski/articles/blob/main/pearson/images/rdrop.png)

### Accounting for Horizontal Lag 

To account for horizontal lag, we can 'brute-force' a solution by just trying a bunch of possible values for 
the offset. Though neither elegant nor efficient, this will work; but only if the offset is a constant value. 
In other words, if the horizontal offset varies over the length of the series, then results will be not so great. 

```
def find_correlation(s1: pd.Series, s2: pd.Series, max_offset:int =-1):
    max_corr = 0
    max_index = 0
    if (max_offset < 0): 
        max_offset = int(len(s1)/2)
        
    for lag in range (max_offset): 
        corr1 = s1.corr(s2.shift(-lag), method='pearson') # thisi is another way to calculate Pearson for Series
        corr2 = s1.corr(s2.shift(lag), method='pearson')
        if (abs(corr1) > abs(max_corr)): 
            max_index = lag
            max_corr = corr1
        if (abs(corr2) > abs(max_corr)): 
            max_index = -lag
            max_corr = corr2
    
    return max_corr, max_index
    
series1, series2 = offset_series(100, h_offset = 5)

c, i = find_correlation(series1, series2)
print(f'max correlation is {c} at index {i}')

c, i = find_correlation(series2, series1)
print(f'max correlation is {c} at index {i}')
```

This tactic of just trying different values for horizontal offset is sometimes called _cross-correlation_. 
There is another method that will account for an offset value that varies over the length of the series, 
called _dynamic time warping_ or dtw (see Python's _dtw_ package).

![figure 15](https://github.com/jrkosinski/articles/blob/main/pearson/images/offset_correlation.png)

Just to tie everything together, I've put together this small class that will attempt to find all obvious 
correlations in all combinations of columns of a given pandas DataFrame, using only Pearson correlation. 

```
class ColumnCorrelation: 
    def __init__(self, col_1_name: str, col_2_name: str, correlation: float, offset:int): 
        self.col_1_name = col_1_name
        self.col_2_name = col_2_name
        self.correlation = correlation
        self.offset = offset 
        
def find_dataset_correlation(df: pd.DataFrame): 
    results = list()
    
    for i in range(len(df.columns)): 
        primary = df[df.columns[i]]
        
        for n in range(i+1, len(df.columns)): 
            corr, index = find_correlation(primary, df[df.columns[n]])
            results.append(
                ColumnCorrelation(
                    df.columns[i], df.columns[n], 
                    corr, index
                )
            )
    return results
```

```
df = pd.DataFrame()

sa, sb = correlated_series(100, 0.1)
df['a'] = sa
df['b'] = sb

sc, sd = mirrored_series(100)
df['c'] = sc
df['d'] = sd

se, sf = offset_series(107, v_offset = 0.5, h_offset=7)
df['e'] = se
df['f'] = sf

df['g'] = sa
df['h'] = sa * -1
```

```
def find_and_report_correlations(df: pd.DataFrame): 
    results = find_dataset_correlation(df)

    for i in range(len(results)):
        r = results[i]
        R = r.correlation 
        adj = '' 
        direction = 'directly' if R > 0 else 'inversely'
        if (abs(R) > 0.3): 
            adj = 'weakly'
            if (abs(R) > 0.6):
                adj = 'moderately'

                if (abs(R) > 0.8):
                    adj = 'strongly'
                if (abs(R) > 0.9):
                    adj = 'very strongly'
                if (abs(R) >= 1):
                    adj = 'perfectly'

                print(f'{r.col_1_name} is {adj} {direction} correlated to {r.col_2_name} with R={R} at offset {r.offset}')
                
find_and_report_correlations(df)
```

![figure 15](https://github.com/jrkosinski/articles/blob/main/pearson/images/correlation_report.png)

### Multi-Feature Correlation  

Correlation can be hidden in such a way that a simple measure like Pearson will have trouble finding the true 
nature of the correlation. In the example below, I have two series s1 and s2 which are both random and uncorrelated, 
and a third series (s3) which is made from the difference between s1 and s2. Pearson will find moderate correlation
between s3->s1, and s3->s2, but of course the true nature of the correlation will require more advanced methods. 

In a case like this, the Pearson correlation is hinting at a possible deeper relationship between the data features, 
but not directly finding that relationship. 

```
def differentially_correlated_series(length: int): 
    s1 = random_series(length)
    s2 = random_series(length)
    s2 *= -1
    s3 = abs(s1) - abs(s2)
    return s1, s2, s3
```

```
s1, s2, s3 = differentially_correlated_series(100)

plt.plot(s1)
plt.plot(s2)
plt.plot(s3)
```

![figure 16](https://github.com/jrkosinski/articles/blob/main/pearson/images/differential_corr.png)

```
df = pd.DataFrame()
df['s1'] = s1
df['s2'] = s2
df['s3'] = s3

find_and_report_correlations(df)
```

![figure 17](https://github.com/jrkosinski/articles/blob/main/pearson/images/differential_report.png)

## Conclusion 

What we have found and observed about Pearson Correlation: 

- What it is: a simple measure of correlation between two data series _x_ and _y_

- What it _can_ do: 
    -- measure the amount of correlation 
    -- indicate the type of correlation: inverse or direct 
    -- find correlation even if _x_ and _y_ are significantly distant vertically
    
- What it _can't_ do: 
    -- find correlation if _x_ and _y_ are even slightly horizontally offset 
    -- directly find 
    
- What it can be used for: 
    -- finding horizontally offset correlation, if used in a process designed to do so 
    -- indicating possible deeper relationships between data features that might bear further investigation, 
    without directly revealing them 
