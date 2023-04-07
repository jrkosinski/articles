// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "../inc/AccessControl.sol";
import "./ISecurityManager.sol";

contract SecurityManager is AccessControl, ISecurityManager { 
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    
    constructor(address admin) {
        _grantRole(ADMIN_ROLE, admin);
    }
    
    function hasRole(bytes32 role, address account) public view virtual override(AccessControl, ISecurityManager) returns (bool) {
        return super.hasRole(role, account);
    }
    
    // added this to avoid accidentally removing admin 
    function renounceRole(bytes32 role, address account) public virtual override  {
        if (role != ADMIN_ROLE) {
            super.renounceRole(role, account);
        }
    }
    
    // added this to avoid accidentally removing admin 
    function revokeRole(bytes32 role, address account) public virtual override  {
        if (account != msg.sender || role != ADMIN_ROLE) {
            super.revokeRole(role, account);
        }
    }
}