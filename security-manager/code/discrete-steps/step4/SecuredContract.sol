// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./ISecurityManager.sol"; 

contract SecuredContract {
    
    //roles 
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant ADMIN_ROLE = bytes32(0);
    
    //the security manager instance 
    // changed from SecurityManager to ISecurityManager
    ISecurityManager public securityManager;
    
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
    constructor(ISecurityManager _securityManager) {
        securityManager = _securityManager;
    }
}