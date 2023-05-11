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


```
