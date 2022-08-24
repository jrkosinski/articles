# article-nft-fails

## Include Price and Sale Information and Logic in your Contract 
### This is very common 
### This is a noob move 
### Motivation: why not put everything in one contract? It's simpler and cheaper and everything's in one place (common sense) 
### Reasons not to do this 
#### It tightly couples your contract to sale logic and functionality 
#### Your contract will never change, but your sale strategy might 
### Reasons to implement loosely coupled design 
#### It lets you change your logic in the future without disrupting anything 
#### It lets your contract logic be mutable in a way that doesn't harm user trust and can't be used to rug-pull. 
#### Your contract should not be handling money directly 

## Don't Implement Role-Based Security
### Related to anove 
### Reasons to not implement role-based security 
#### You "know" you will be the only one managing the contract 
#### You want to keep things simpler 
### Reasons to implement role-based security 
#### It's not that much more complicated 
#### It allows you to decouple components (like minting and selling) from the contract 
### Recommendation: OpenZeppelin 

## Don't Implement ERC-165 (Introspection) Properly 
### Reasons to Implement ERC-165: 
#### Interoperability 
#### future compatibility with standards 
#### exchanges may call it (e.g. 2981 for royalties) 
#### you want your contract (especially token contracts) to be as interoperable as possible, and as compatible with as many exchanges as possible (including future ones) 

## Don't Use OpenZeppelin Libraries and Contracts

## Don't Test Thoroughly Before Deploying
### Reasons to not test 
#### You're using OZ, and everythings already been tested 
### Reasons to test 
#### You may have broken something 
#### You only have one shot to deploy to mainnet 
