// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./SecuredContract.sol"; 

contract Contract2 is SecuredContract {
    uint256 public publicValue = 0;
    uint256 public restrictedValue2 = 0;
    
    //changed to ISecurityManager
    constructor(ISecurityManager _securityManager) SecuredContract(_securityManager) {
    }
    
    function publicMethod(uint256 value) external {
        //implementation
        publicValue = value;
    }
    
    function setRestrictedValue2(uint256 value) external onlyRole(MANAGER_ROLE) {
        //implementation
        restrictedValue2 = value;
    }
}