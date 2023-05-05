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


### What is Pearson's Coefficient Used For? 

Pearson's correlation is used to help answer the question: are the variables X and Y correlated, to what extent, and is that correlation negative or positive? The value can be used to pre-select certain features for further processing or use in a machine learning algorithm. 
