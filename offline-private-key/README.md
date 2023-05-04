Safely Storing an Offline Private Key 

OUTLINE 

1. Don't. 
2. Do: store it encrypted (show how using ethers) 
3. Do: store different parts in different locations with different access credentials so that it's harder for one person to have access 
4. Do: keep your on-chain security compartmentalized and don't give admin rights to devs 
5. Do: keep your off-chain security compartmentalized as well (and don't give admin rights to devs)
6. Do: Obfuscate the information (and pass it on by word of mouth)
7. Do: change out your private key regularly 

Conclusion 



# Storing Web3 Application Private Keys Safely 

There comes a time in the life of some web3 applications when it becomes necessary to store a private key on a server, 
for use by off-chain processes accessing the blockchain environment. This comes with inherent security risks which _cannot_ be entirely negated. 
That bears repeating: you are taking on risk by doing this. I would like to propose some tested ways to mitigate (not eliminate) these risks. 


## 1. Just Don't Do It

Yes, consider very carefully whether or not there's another way to do what you need to do, which doesn't require storing a private key in a file. 
This should be (and is) #1. 

It is preferable from a security standpoint to keep private keys out of files that live on public servers. For example, whatever process that is to be executed
using this private key: is there any way to make it a manual process, that can be initiated by an individual with the appropriate security privileges, 
via a web3 admin console using Metamask or another secure wallet? 

Consider carefully the advantages and drawbacks of doing so. If it's possible to sacrifice a bit of convenience for the peace of mind that security brings, 
it should be seriously considered. The decision to store a private key in a file on a server should not be taken lightly. 


## 2. DO: Encrypt the Private Key Before Storing 

If it comes down to it, don't store the private key unencrypted. It can be easily encrypted using this: 

A reasonable objection might be: if the private key is encrypted, and the code needs access to it, then the code needs access to the decryption key. So 
did you really solve any problem? 


## 3. DO: Store the Decryption Key Behind Several Locked Doors


## 4. DO: Keep your Off-Chain Security Access Compartmentalized 


## 5. DO: Keep your On-Chain Security Access Compartmentalized 


## 6. DO: Obfuscate  

Don't make it obvious to a casual observer that the decryption key (or the private key for that matter, or any sensitive data) is what it actually is. 


## 7. DO: Switch Out the Private Key Regularly 

