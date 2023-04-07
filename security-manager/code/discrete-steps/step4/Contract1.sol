// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./SecuredContract.sol"; 

contract Contract1 is SecuredContract {
    uint256 public publicValue = 0;
    uint256 public restrictedValue1 = 0;
    
    //changed to ISecurityManager
    constructor(ISecurityManager _securityManager) SecuredContract(_securityManager) {
    }
    
    function publicMethod(uint256 value) external {
        //implementation
        publicValue = value;
    }
    
    function setRestrictedValue1(uint256 value) external onlyRole(ADMIN_ROLE) {
        //implementation
        restrictedValue1 = value;
    }
}