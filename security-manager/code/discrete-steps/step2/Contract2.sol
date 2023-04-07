// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./SecurityManager.sol"; 

// Contract1 has been split into 2 contracts, Contract1 and Contract2. This is to showcase the code reuse.
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
    
    function setRestrictedValue2(uint256 value) external { // this method is for MANAGER role only
        require (
            securityManager.hasRole(keccak256("MANAGER_ROLE"), msg.sender),
            "Caller not authorized"
        );
        
        //implementation
        restrictedValue2 = value;
    }
}