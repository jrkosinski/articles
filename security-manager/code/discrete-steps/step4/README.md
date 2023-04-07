- create ISecurityManager interface in a new file 
- make SecurityManager implement ISecurityManager 
- change all reference to SecurityManager in SecuredContract and Contract1/2 to ISecurityManager 

We will create an interface called ISecurityManager, and make SeceurityManager implement it. 

Aside from the usual benefits of hiding implementations behind interfaces, there is a real practical reason for this as well; and to achieve the benefit you'll need to store ISecurityManager and SecurityManager in different .sol files. When you deploy new contracts that reference an existing on-chain SecurityManager, you won't need to deploy all of the SecurityManager contract's code with it; just only the interface. Not only is it unnecessary to re-deploy the SecurityManager implementation, doing so can significantly add to your deployment costs!  