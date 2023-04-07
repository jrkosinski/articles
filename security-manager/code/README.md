# Security Manager Design Pattern in Solidity 

Thought of the day: Lots of people have ideas; the real skill is in turning those ideas into reality. 
-----------------------------------------------------------------------------------------------------------------------------------

Design patterns in software have been around a long time. Many have not changed much over the years (see Gang of Four) because they're based on fundamental building blocks of logic itself, and they're useful for most types of logical machines. When it comes to blockchain, some common long-held standards of development are infeasible or inadvisable (take the humble looping construct as a simple example). Some standard OOP design patterns are perfectly good and advisable in blockchain (smart contract) architecture, others usable with some modification; still others not at all. 

Design patterns are just that - patterns of behavior in development that we may find in our own code, in the wild, or that we may dream up to solve a particular problem. Today I'd like to document a common pattern that I find myself using (and I'm sure that many others do too), because it solves a particular problem elegantly. 

This pattern relates to contract security. It's not specific to blockchain, but it is particularly applicable in smart contract development, and I think the reasons for this will be evident. It's not complicated, and it probably exists under many names, but I'm going to call it the Security Manager pattern. This pattern and the accompanying examples focus on Solidity development for any EVM compatible chain, but it can be applied (with applicable modifications) to other blockchain architectures as well. The examples and discourse focus on role-based security (because it's the most common use case), but one should be able to easily apply it just as well to other security models.

This is the first in a planned multi-part series in which I'll write about security topics in blockchain development from a few different angles.

## Situation: 
- For most non-trivial use cases, your DApp consists of not just one contract, but a happy family of smart contracts. Some (maybe most, maybe all) expose protected methods that should only be called from permissioned accounts. 
- For this situation, we're going to assume that the various use cases converge on the best security model being role-based security. The pattern can be applied just as well to other security models.

## Naive Implementation: 
- Every contract in the family that requires some security will inherit individually from OpenZeppelin's [AccessControl](https://docs.openzeppelin.com/contracts/2.x/access-control)

While this will solve the basic need of having security restrictions present on the contracts that need them, it comes with some drawbacks: 

## Problems with the Naive Implementation: 
**Code bloat**. If you're not as familiar with on-chain development, know that you'll be baking the AccessControl class into each one of your deployed contracts; the code will be reused only in a logical sense, but not in an actual physical sense. You will multiply the amount of code to be deployed for each contract that inherits from AccessControl; the code is not truly shared in that sense. And that implies... 

**Deployment costs**.
Deployment costs can be non-trivial, especially if you'll be deploying the same family of contracts more than once (on different chains for example, or as different instances on the same chain). The increased amount of code can significantly increase deployment costs. (Relevant to my example, OpenZeppelin dependencies can grow large, and therefore expensive to deploy)

**Operating costs**.
This refers to gas costs for making security-related changes on the contracts. Scenario: you want to add three members to the ADMIN role. You have six contracts that implement role-based security, and these three new members should have admin rights on each of the six contracts. That's 18 network calls you have to make, when it should be just three (or even just one, if you want to allow multiple assignments per call). 

**Potential for mistakes**.
When you are adding or removing roles, and you have to perform the same operations on multiple contracts, the potential for mistakes is higher. This can result in _not_ removing a security risk address from one or more of several contracts, when that was the intention. 

**Same security roles defined multiple times**. 
A small inconvenience, but if several of your contracts recognize the same security roles, you'll have to redefine each of those roles on each of the contracts that need them; it's inconvenient and also increases the chance of mistakes/bugs.

**Violates the R in DRY**. 
Makes you repeat yourself, as you'll end up implementing similar or identical code to manage security on each of the contracts that need it. 


## How the Pattern Solves the Problems: 
- Solves the problem of code bloat: the reused code is both logically and physically separated, so you won't be deploying the same code multiple times. 

- Reduces deployment costs, as you will be deploying the access control code not multiple times, but just once. 

- Reduces operating costs, as security management operations (grant role, revoke role, etc.) are done in one place with a minimum number of operations. Mitigates the chances of potential security oversights for the same reason. 

- Solves the problem of multiple definitions of the same security roles; they're defined only in the Security Manager. 

- Puts the R back in DRY by eliminating all redundant security-related code, definitions, and declarations. 


## Extra Perks of the Design: 
- If your situation allows, a single Security Manager can be used across multiple _instances_ of your entire contract network. Furthermore, if your situation allows, it can even be used across projects, and the projects don't even need to be related in any other way (though you should really _really_ examine your use cases to determine if this will benefit you in the long run). 

- No inheritance is used, so you avoid muddying your inheritance graph. Solidity's multiple inheritance model is a touchy subject, and some people dogmatically reject the idea of multiple inheritance entirely. This model avoids that entire issue because your contracts reference the Security Manager, but don't extend a base class. 

- The modular design is flexible in that it _allows_ you to centralize security, without _requiring_ you to do so. Imagine, for example, a network of 5 contracts (not including the Security Manager), in which 3 of them use Security Manager A, and 2 use Security Manager B. Two different Security Managers serve the network (and presumably that's for a valid reason - i.e. a different security profile for each sub-group of contracts). That's entirely possible. It's also possible to later bring them under the umbrella of one unified Security Manager. It's possible to discard the current Security Manager (without upgrading any contracts) and plug in a new one. If in the future, each contract needs its own individual tailor-made Security Manager, that can be done as well; the design is modular so it allows for different types of flexibility. 


## Security Manager Implementation: 

All code for this example is here: [view code on github](https://github.com/jrkosinski/articles/blob/main/security-manager/code/)

### Step 0: Naive Implementation

[view code on github](https://github.com/jrkosinski/articles/blob/main/security-manager/code/discrete-steps/step0/Contract1.sol)

- implement one contract that controls its own security, via OpenZeppelin's AccessControl (role-based security)

This exemplifies the naive implementation described above, wherein each contract individually handles its own security.

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../inc/AccessControl.sol";

//note that this contract inherits AccessControl directly
contract Contract is AccessControl {
    uint256 public publicValue = 0;
    uint256 public restrictedValue1 = 0;
    uint256 public restrictedValue2 = 0;
    
    constructor() {
    }
    
    function publicMethod(uint256 value) external {
        //implementation
        publicValue = value;
    }
    
    // restricted method 1
    function setRestrictedValue1(uint256 value) external onlyRole(keccak256("ADMIN_ROLE")) {
        //implementation
        restrictedValue1 = value;
    }
    
    // restricted method 2
    function setRestrictedValue2(uint256 value) external onlyRole(keccak256("MANAGER_ROLE")) {
        //implementation
        restrictedValue2 = value;
    }
}
```

### Step 1: Add Security Manager

[view code on github](https://github.com/jrkosinski/articles/tree/main/security-manager/code/discrete-steps/step1)

- implement a SecurityManager contract
- modify the Contract to use a reference to SecurityManager instead of inheriting AccessControl

Here, a SecurityManager contract is created (which controls access via OpenZeppelin's AccessControl), and Contract is changed so that it refers to an instance of the SecurityManager. See that SecurityManager provides the necessary access to the underlying security protocols, by allowing callers to query, revoke, renounce, and grant roles. 

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../inc/AccessControl.sol";

//note that this contract now takes on the job of inheriting AccessControl
contract SecurityManager is AccessControl {
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    
    constructor(address admin) {
        _grantRole(ADMIN_ROLE, admin);
    }
    
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return super.hasRole(role, account);
    }
    
    function renounceRole(bytes32 role, address account) public virtual override  {
        super.renounceRole(role, account);
    }
    
    function revokeRole(bytes32 role, address account) public virtual override  {
        super.revokeRole(role, account);
    }
}
```

The Contract will now be changed so that it holds a reference to SecurityManager. Note that Contract no longer inherits from AccessControl. 

```
contract Contract {
    //the security manager 
    SecurityManager public securityManager;
    
    uint256 public publicValue = 0;
    uint256 public restrictedValue1 = 0;
    uint256 public restrictedValue2 = 0;
    
    // Security Manager is linked at deployment 
    constructor(SecurityManager _securityManager) {
        securityManager = _securityManager;
    }
    
    function publicMethod(uint256 value) external {
        //implementation
        publicValue = value;
    }
    
    // restricted method 1: now uses SecurityManager
    function setRestrictedValue1(uint256 value) external { // this method is for ADMIN role only 
        require (
            securityManager.hasRole(keccak256("ADMIN_ROLE"), msg.sender), 
            "Caller not authorized"
        );
        
        //implementation
        restrictedValue1 = value;
    }
    
    // restricted method 2: now uses SecurityManager
    function setRestrictedValue2(uint256 value) external { // this method is for MANAGER role only 
        require (
            securityManager.hasRole(keccak256("MANAGER_ROLE"), msg.sender),
            "Caller not authorized"
        );
        
        //implementation
        restrictedValue2 = value;
    }
}
```

### Step 2: Split Contract into Two Contracts

[view code on github](https://github.com/jrkosinski/articles/tree/main/security-manager/code/discrete-steps/step2)

- split Contract up into Contract1 and Contract2 
- both contracts will continue to use SecurityManager 

In a real use case, using this pattern with only one single contract is not really providing any benefit. The pattern is for cases in which security must be controlled for multiple contracts. Imagine a production scenario which might contain a handful or even dozens of contracts. This example, for simplicity, will just show two. 

```
contract Contract1 {
    SecurityManager public securityManager;
    uint256 public publicValue = 0;
    uint256 public restrictedValue1 = 0;
    
    constructor(SecurityManager _securityManager) {
        securityManager = _securityManager;
    }
    
    function publicMethod(uint256 value) external {
        //implementation
        publicValue = value;
    }
    
    // Contract1 has restricted method 1
    function setRestrictedValue1(uint256 value) external { // this method is for ADMIN role only 
        require (
            securityManager.hasRole(keccak256("ADMIN_ROLE"), msg.sender), 
            "Caller not authorized"
        );
        
        //implementation
        restrictedValue1 = value;
    }
}

contract Contract2 {
    SecurityManager public securityManager;
    uint256 public publicValue = 0;
    uint256 public restrictedValue2 = 0;
    
    constructor(SecurityManager _securityManager) {
        securityManager = _securityManager;
    }
    
    function publicMethod(uint256 value) external {
        //implementation
        publicValue = value;
    }
    
    // Contract2 has restricted method2
    function setRestrictedValue2(uint256 value) external { // this method is for MANAGER role only
        require (
            securityManager.hasRole(keccak256("MANAGER_ROLE"), msg.sender),
            "Caller not authorized"
        );
        
        //implementation
        restrictedValue2 = value;
    }
}
```

### Step 3: Simplify by Eliminating Redundancy

[view code on github](https://github.com/jrkosinski/articles/tree/main/security-manager/code/discrete-steps/step3)

- implement SecuredContract class
- modify Contract1 and Contract2 to inherit SecuredContract
- replace 'require' with a modifier 

Now that we have two contracts, we see that there is some redundant code. For one thing, that 'require' in each of the restricted could be replaced by a more readable modifier. One way to do this is by creating a common class to hold the common code and making Contract1 and Contract2 subclasses. You can also use a library module or some other method if you prefer; the point here is just to tidy up and avoid repeating ourselves in code.

```
// this class is new; it generalizes the role of a "secured" contract (one which uses the SecurityManager)
contract SecuredContract {
    
    //roles 
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    
    //the security manager instance 
    SecurityManager public securityManager;
    
    //thrown when the onlyRole modifier reverts 
    error UnauthorizedAccess(bytes32 roleId, address addr); 
    
    //Restricts function calls to callers that have a specified security role only 
    modifier onlyRole(bytes32 role) {
        if (!securityManager.hasRole(role, msg.sender)) {
            revert UnauthorizedAccess(role, msg.sender);
        }
        _;
    }
    
    //constructor
    constructor(SecurityManager _securityManager) {
        securityManager = _securityManager;
    }
}

contract Contract1 is SecuredContract {
    uint256 public publicValue = 0;
    uint256 public restrictedValue1 = 0;
    
    constructor(SecurityManager _securityManager) SecuredContract(_securityManager) {
    }
    
    function publicMethod(uint256 value) external {
        //implementation
        publicValue = value;
    }
    
    // restricted method 1 is simplified by use of modifier (still controlled by SecurityManager)
    function setRestrictedValue1(uint256 value) external onlyRole(ADMIN_ROLE) {
        //implementation
        restrictedValue1 = value;
    }
}

contract Contract2 is SecuredContract {
    uint256 public publicValue = 0;
    uint256 public restrictedValue2 = 0;
    
    constructor(SecurityManager _securityManager) SecuredContract(_securityManager) {
    }
    
    function publicMethod(uint256 value) external {
        //implementation
        publicValue = value;
    }
    
    // restricted method 1 is simplified by use of modifier (still controlled by SecurityManager)
    function setRestrictedValue2(uint256 value) external onlyRole(MANAGER_ROLE) {
        //implementation
        restrictedValue2 = value;
    }
}
```

### Step 4: Finishing Touches: Hide SecurityManager Behind Interface

[view code on github](https://github.com/jrkosinski/articles/tree/main/security-manager/code/discrete-steps/step4)

- create ISecurityManager interface in a new file 
- make SecurityManager implement ISecurityManager 
- change all reference to SecurityManager in SecuredContract and Contract1/2 to ISecurityManager 

We will create an interface called ISecurityManager, and make SeceurityManager implement it. 

Aside from the usual benefits of hiding implementations behind interfaces, there is a real practical reason for this as well; and to achieve the benefit you'll need to store ISecurityManager and SecurityManager in different .sol files. When you deploy new contracts that reference an existing on-chain SecurityManager, you won't need to deploy all of the SecurityManager contract's code with it; just only the interface. Not only is it unnecessary to re-deploy the SecurityManager implementation, doing so can significantly add to your deployment costs!  

```
// this generalizes the interface of SecurityManager and hides its implementation
interface ISecurityManager {
    function hasRole(bytes32 role, address account) external view returns (bool);
}

// SecurityManager now is an ISecurityManager as well 
contract SecurityManager is AccessControl, ISecurityManager { 
    .... 
```

Now everywhere that formerly referred to SecurityManager, can refer instead to ISecurityManager. The purpose of this is to reduce code bloat at deployment of new contracts. 

```
contract Contract1 is SecuredContract {
    uint256 public publicValue = 0;
    uint256 public restrictedValue1 = 0;
    
    // here, and in other places, refer to ISecurityManager instead of SecurityManager directly
    constructor(ISecurityManager _securityManager) SecuredContract(_securityManager) { }
    .... 
```
    
### Step 5: Finishing Touches: Prevent Accidental Stranding

[view code on github](https://github.com/jrkosinski/articles/tree/main/security-manager/code/discrete-steps/step5)

- add code to SecurityManager.revokeRole to prevent stranding
- add code to SecurityManager.renounceRole to prevent stranding

When using role-based security, typically there is one role that's allowed to grant roles to accounts. If a contract was left without any users holding that one role (for example, if the one single admin accidentally revoked his own admin role), there could be no way for anyone to regain that role, short of redeploying the entire set of contracts. 

For this, I just (my own best practice here) like to add some protection against that. If the caller is ADMIN, in this case, the caller is not allowed to either renounce or revoke his _own_ admin role. Note that he can renounce the admin roles of other admins, just not his own. This makes it much less likely to encounter a death stranding situation. 

In SecurityManager.sol: 
```
    // this is added to prevent against accidentally renouncing the admin role of the only remaining admin 
    function renounceRole(bytes32 role, address account) public virtual override  {
        if (role != ADMIN_ROLE) {
            super.renounceRole(role, account);
        }
    }
    
    // this is added to prevent against accidentally revoking the admin role of the only remaining admin 
    function revokeRole(bytes32 role, address account) public virtual override  {
        if (account != msg.sender || role != ADMIN_ROLE) {
            super.revokeRole(role, account);
        }
    }
```

### Further Steps 

[view code on github](https://github.com/jrkosinski/articles/tree/main/security-manager/code/contracts)

In the code linked above, you can see that I've added some extra niceties. 
- public method allows admin to change to a new SecurityManager (SecuredContract class, setSecurityManager) 
- added extra checks when setting SecurityManager, in both the constructor and setSecurityManager method (e.g. zero address check)
- comments 
- custom errors 


Some notes about the above example: 

* It's highly simplified for clarity
* The examples use OpenZeppelin's AccessControl for role-based security. In reality, the technique is not specific to either OpenZeppelin or role-based security. Almost any security implementation should be usable. 
* I mentioned earlier that one of the side benefits is that it reduces the use of inheritance. Actually, inheritance is still used for SecurityManager, but that's (a) optional, and (b) only single inheritance. Inheritance is also used for SecuredContract -> Contract1 and Contract2, but that's optional; there are other ways to reduce code reuse (like libraries and such). 
* Changes to security roles (e.g. granting roles, revoking roles) is all done directly on the SecurityManager. That's why ISecurityManager doesn't implement those methods (it only implements the methods needed by client contracts). 


## Conclusion 

This has been an example of a design pattern that is suited well to use for EVM-compatible contract design - and smart contract design in general - for the reasons outlined above. The purpose of the pattern is to implement a security while increasing modularity and reuse, and decreasing code bloat. 

See the pattern in the wild here: 
[https://bscscan.com/address/0x65aFe9D3cfE457271a78D86638F7834e2d4b11Fd#code](https://bscscan.com/address/0x65aFe9D3cfE457271a78D86638F7834e2d4b11Fd#code)

Please check out my github if you're interested in discussing a project: 
https://github.com/jrkosinski/Smart-Contract-Architect-Develeoper

-----------------------------------------------------------------------------------------------------------------------------------
