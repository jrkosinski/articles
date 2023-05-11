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

[IMAGE of PEARSON]


## What is the Pearson measure good for? 

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

![figure 5](https://github.com/jrkosinski/articles/blob/main/pearson/images/hoffset.png)

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
![figure 6](https://github.com/jrkosinski/articles/blob/main/pearson/images/rdrop.png)

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

![figure 10](https://github.com/jrkosinski/articles/blob/main/pearson/images/offset.png)

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
![figure 12](https://github.com/jrkosinski/articles/blob/main/pearson/images/offset.png)
