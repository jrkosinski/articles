// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./SecurityManager.sol"; 

// Contract1 has been split into 2 contracts, Contract1 and Contract2. This is to showcase the code reuse.
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
    
    function setRestrictedValue1(uint256 value) external { // this method is for ADMIN role only 
        require (
            securityManager.hasRole(keccak256("ADMIN_ROLE"), msg.sender), 
            "Caller not authorized"
        );
        
        //implementation
        restrictedValue1 = value;
    }
}