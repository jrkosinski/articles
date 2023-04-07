// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./SecurityManager.sol"; 

contract Contract1 {
    SecurityManager public securityManager;
    uint256 public publicValue = 0;
    uint256 public restrictedValue1 = 0;
    uint256 public restrictedValue2 = 0;
    
    constructor(SecurityManager _securityManager) {
        securityManager = _securityManager;
    }
    
    function publicMethod(uint256 value) external {
        //implementation
        publicValue = value;
    }
    
    function setRestrictedValue1(uint256 value) external { // this method is for ADMIN role only 
        require (
            securityManager.hasRole(bytes32(0)), msg.sender), 
            "Caller not authorized"
        );
        
        //implementation
        restrictedValue1 = value;
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