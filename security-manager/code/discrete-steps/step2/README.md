- split Contract up into Contract1 and Contract2 
- both contracts will continue to use SecurityManager 

In a real use case, using this pattern with only one single contract is not really providing any benefit. The pattern is for cases in which security must be controlled for multiple contracts. Imagine a production scenario which might contain a handful or even dozens of contracts. This example, for simplicity, will just show two. 