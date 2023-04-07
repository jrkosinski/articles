// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./SecurityManager.sol"; 

// SecuredContract can be inherited by any contract that uses SecurityManager
contract SecuredContract {
    
    //roles 
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant ADMIN_ROLE = bytes32(0);
    
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