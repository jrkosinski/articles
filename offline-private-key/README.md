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

The overarching philosophy is this: 
Security is not an all-or-nothing battle. Good security is a matter of constructing enough obstacles to make an attack prohibitively inconvenient and expensive to the extent that it's unlikely that an attacker will continue, and more likely that the attacker will move on to an easier target. So for anyone imagining security as being an insurmountable wall, I would say to them that such a thing doesn't exist. Rather, good security is a tangle of barbed wire, trenches, and smaller obstacles to make a potential attacker likely to give up (probably for an easier target). In this view, one needn't run faster than the lion, but just faster than the slowest antelope. And the key takeaway is: many small to medium-sized obstacles. 


## 1. Just Don't Do It

Yes, consider very carefully whether or not there's another way to do what you need to do, which doesn't require storing a private key in a file. 
This should be (and is) #1. 

It is preferable from a security standpoint to keep private keys out of files that live on public servers. For example, whatever process that is to be executed
using this private key: is there any way to make it a manual process, that can be initiated by an individual with the appropriate security privileges, 
via a web3 admin console using Metamask or another secure wallet? 

Consider carefully the advantages and drawbacks of doing so. If it's possible to sacrifice a bit of convenience for the peace of mind that security brings, 
it should be seriously considered. The decision to store a private key in a file on a server should not be taken lightly. Seriously try to avoid it. 

The following statement should be true: 
"We have considered all possible options, and we've decided that storing the private key on a server is not avoidable". 


## 2. DO: Encrypt the Private Key Before Storing 

If it comes down to it, don't store the private key unencrypted. It can be easily encrypted: 

[EXAMPLE]

A reasonable objection might be: if the private key is encrypted, and the code needs access to it, then the code needs access to the decryption key. So 
did you really solve any problem? The answer to that will be in the next section. 

The following statement should be true: 
"The private key is not stored _anywhere_ on this green earth in raw unencrypted characters". 

## 3. DO: Store the Decryption Key Behind Several Locked Doors

If we have a private key encrypted, then we have to also store the key to decrypt it so that it can be used. The key here is to not store the decryption key in the same place as the encrypted data, but to store it in a different location _that requires different security permissions to access_. In this way, an individual would need more than one set of security permissions in order to access both the encrypted data, and the key to decrypt it. This reduces the likelihood of any given person being able to access it; if a potential attacker gained access to the server on which the encrypted private key resides, he'd find that he also needs access to the database (or another server, or an s3 storage bucket, etc.) in order to decrypt it. With only one of those two permissions, the data is either inaccessible or useless. It's another barrier. 

And to take it one step further, the decryption key can be split up and stored in multiple places, each with its own security permission needed to access it. 
[CONTINUE TO ELABORATE]

The following statement should be true: 
"One would need to be explicitly granted access to several different entities, in order to fully access a private key and decrypt it". 
"These privileges are given out only as needed, and normally no one single individual has all of them at once". 

## 4. DO: Keep your Off-Chain Security Access Compartmentalized 

The point in #3 above would be useless is everyone was given all permissions. Permissions off-chain must be compartmentalized, so that each person or entity has access only to what it needs. 

The following statement should be true: 
""

## 5. DO: Keep your On-Chain Security Access Compartmentalized 

The following statement should be true: 
"Anyone who has gained access to an unencrypted private key can only do ___, but they can't use it to access everything or own the app (and they can't use it to grant their own permissions)". 

## 6. DO: Obfuscate  

Don't make it obvious to a casual observer that the decryption key (or the private key for that matter, or any sensitive data) is what it actually is. 

The following statements should be true: 
"Without a very detailed pre-existing knowledge of the codebase, it would be difficult and time-consuming to glean an understanding from the code that a private key is stored somewhere, where it is stored, and how it is decrypted". 
"The instructions on how to get this information are passed on by word of mouth, and not written down". 

## 7. DO: Switch Out the Private Key Regularly 

The following statements should be true: 
"Each private key is used for no longer than 1 month (or less)". 
"Retired private keys are completely useless to anyone; anyone with access to one gains no special powers". 
